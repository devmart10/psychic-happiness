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
        print('usage: python3 graph_network.py <file_in> <file_out')
        print('usage: python3 graph_network.py  -d <directory>')
        quit()
    if '-d' in sys.argv:
        d_out = './pics/'
        os.makedirs(d_out, exist_ok=True)
        walk_directory(str(sys.argv[2]), d_out)
    else:
        # if you want to simply supply a file
        #
        filename = str(sys.argv[1])
        out = str(sys.argv[2])
        create_network_graph(filename, out)


def walk_directory(d_main, d_out):
    # traverse root directory, and list directories as dirs and files as files
    for root, dirs, files in os.walk(d_main):
        for file in files:
            if '.' not in file and 'Genome_' in file: # don't open other file types
                filename = os.path.join(root, file)
                # create_network_graph(filename, str(filename + '.png')) # TODO: this could be safer
                out_name = str(filename.replace('/', '_') + '.png')
                out_full = os.path.join(d_out, out_name)
                create_network_graph(filename, out_full) # TODO: this could be safer

def create_network_graph(data_file, output_file):
    data = {}
    print('parsing: %s' % data_file)
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
    
    genes = data['genes']

    genome = [f for f in data_file.split('/') if 'Genome_' in f][0]
    genome_num = int(genome.split('_')[1])

    species = [f for f in data_file.split('/') if 'Species_' in f][0]
    spec_num = int(species.split('_')[1])

    gen = [f for f in data_file.split('/') if 'Generation_' in f][0]
    gen_num = int(gen.split('_')[1])

    network = plotNN.DrawNN( [input_layer, output_layer], genes, data )
    network.draw(output_file, (gen_num, spec_num, genome_num))

if __name__ == '__main__':
    main()
