import json
import os
import sys
import shutil
import tempfile
import plistlib
import argparse

from BuildEnvironment import run_executable_with_output, check_run_system


import base64


def get_certificate_base64():
    certificate_data = run_executable_with_output('security', arguments=['find-certificate', '-c', 'Apple Distribution: Telegram FZ-LLC (C67CF9S4VU)', '-p'], check_result=False)
    certificate_data = certificate_data.replace('-----BEGIN CERTIFICATE-----', '')
    certificate_data = certificate_data.replace('-----END CERTIFICATE-----', '')
    certificate_data = "".join(certificate_data.split())
    if not certificate_data:
        pub_cert_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'fake-codesigning', 'certs', 'Public.cer')
        if os.path.exists(pub_cert_path):
            with open(pub_cert_path, 'rb') as f:
                certificate_data = base64.b64encode(f.read()).decode('ascii')
    return certificate_data


def process_provisioning_profile(source, destination, certificate_data):
    with open(source, 'rb') as f:
        raw = f.read()
    start = raw.find(b'<?xml')
    end = raw.find(b'</plist>')
    if start != -1 and end != -1:
        plist_bytes = raw[start:end + len(b'</plist>')]
        plist = plistlib.loads(plist_bytes)
    else:
        parsed_plist = run_executable_with_output('security', arguments=['cms', '-D', '-i', source], check_result=True)
        plist = plistlib.loads(parsed_plist.encode('utf-8'))

    if isinstance(certificate_data, str):
        cert_bytes = base64.b64decode(certificate_data)
    else:
        cert_bytes = certificate_data

    plist['DeveloperCertificates'] = [cert_bytes]
    if 'DER-Encoded-Profile' in plist:
        del plist['DER-Encoded-Profile']

    fd, parsed_plist_file = tempfile.mkstemp(suffix='.plist')
    with os.fdopen(fd, 'wb') as file:
        plistlib.dump(plist, file)

    try:
        run_executable_with_output('security', arguments=['cms', '-S', '-N', 'Apple Distribution: Telegram FZ-LLC (C67CF9S4VU)', '-i', parsed_plist_file, '-o', destination], check_result=True)
    finally:
        if os.path.exists(parsed_plist_file):
            os.unlink(parsed_plist_file)


def generate_provisioning_profiles(source_path, destination_path):
    certificate_data = get_certificate_base64()

    if not os.path.exists(destination_path):
        print('{} does not exist'.format(destination_path))
        sys.exit(1)

    for file_name in os.listdir(source_path):
        if file_name.endswith('.mobileprovision'):
            process_provisioning_profile(source=source_path + '/' + file_name, destination=destination_path + '/' + file_name, certificate_data=certificate_data)
