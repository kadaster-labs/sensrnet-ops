#!/usr/bin/python

import sys
import subprocess
import json
from optparse import OptionParser


def run_command(command):
    print("Running: {}".format(command))
    try:
        output = subprocess.check_output(
            command, stderr=subprocess.STDOUT, shell=True)
    except subprocess.CalledProcessError as exc:
        print("Status: FAIL, ", exc.output.decode('ascii'))
    else:
        print("Output: {}".format(output.decode('ascii')))


def build_commands(json_file, cluster):
    commands = []
    all_secrets = json.load(json_file)
    secrets_for_cluster = all_secrets[cluster]

    for namespace, secrets in secrets_for_cluster.items():
      for secret, data in secrets.items():
        command = 'kubectl create secret generic {} --namespace {}'.format(secret, namespace)

        for literal_key, literal_value in data.items():
          command += ' --from-literal={}={}'.format(literal_key, literal_value)

        commands += [command]

    return commands


def main(argv):

    required = "cluster inputfile".split()

    parser = OptionParser()
    parser.add_option("-C", '--cluster',
                      action="store", type="string", dest='cluster')
    parser.add_option("-I", '--inputfile',
                      action="store", type="string", dest='inputfile')

    (options, args) = parser.parse_args()

    for r in required:
        if options.__dict__[r] is None:
            parser.error("parameter %s required" % r)

    cluster = options.cluster
    inputfile = options.inputfile

    print('')
    print('Cluster is: ', cluster)
    print('Input file is: ', inputfile)
    print('')

    with open(inputfile) as json_file:
        commands = build_commands(json_file, cluster)
        for command in commands:
            run_command(command)

    print('')
    print('Done!')


if __name__ == "__main__":
    main(sys.argv[1:])
