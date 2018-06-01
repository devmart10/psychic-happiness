import matplotlib
matplotlib.use('Agg')

import os
import sys
import json
from pprint import pprint as pp

import numpy as np
import matplotlib.pyplot as plt

import plotNN

def main():
    if len(sys.argv) < 2:
        print('usage: python3 graph_network.py <directory>')
        quit()
    walk_directory(sys.argv[1])

    # if you want to simply supply files
    #
    # for filename in list(map(str, sys.argv)):
    #     create_network_graph(filename, str(filename + '.png'))

def walk_directory(d_main):
    # traverse root directory, and list directories as dirs and files as files
    for root, dirs, files in os.walk(d_main):
        for file in files:
            if '.' not in file and 'Genome_' in file: # don't open other file types
                filename = os.path.join(root, file)
                create_network_graph(filename, str(filename + '.png')) # TODO: this could be safer

def create_network_graph(data_file, output_file):
    data = {}
    pp('opening: %s' % filename)
    with open(data_file, 'r') as f:
        data = json.load(f)
    network = data['network']
    input_layer = {}
    output_layer = {}
    for index in sorted(network):
        neuron = network[index]
        if int(index) >= 100000:
            output_layer[index] = neuron
        else:
            input_layer[index] = neuron
    
    network = plotNN.DrawNN( [input_layer, output_layer] )
    network.draw(output_file)

if __name__ == '__main__':
    main()