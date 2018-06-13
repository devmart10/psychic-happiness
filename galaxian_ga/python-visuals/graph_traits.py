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
        print('usage: python3 graph_traits.py <directory> <output>')
        quit()

    d_main = str(sys.argv[1])
    out_file = str(sys.argv[2])
    create_generation_graph(d_main, out_file + '.gen.png')
    create_species_graph(d_main, out_file + '.spec.png')

def create_generation_graph(d_main, out_file):
    all_generations = get_generation_dict(d_main)

    x = []
    y_avg = []
    y_max = []
    y_min = []
    for gen in sorted(all_generations):
        avg_fitness = get_avg_fitness(all_generations[gen])
        max_fitness = max(list(map(lambda x: x['fitness'], all_generations[gen])))
        min_fitness = min(list(map(lambda x: x['fitness'], all_generations[gen])))
        x.append(gen)
        y_avg.append(avg_fitness)
        y_max.append(max_fitness)
        y_min.append(min_fitness)

    fig = plt.figure()

    x = np.array(x)
    y_avg = np.array(y_avg)
    y_max = np.array(y_max)
    y_min = np.array(y_min)

    plt.plot(x, y_max, label='Max')
    plt.plot(x, y_min, label='Min')
    plt.plot(x, y_avg, label='Average')

    plt.title('Fitness by Generation', fontsize=15)
    plt.xlabel('Generation')
    plt.ylabel('Fitness')

    plt.legend(loc=1)
    plt.tight_layout()

    fig.savefig(out_file)
    plt.close(fig)

def create_species_graph(d_main, out_file):
    all_species = get_species_dict(d_main)

    x = []
    y_avg = []
    y_max = []
    y_min = []
    for spec in sorted(all_species):
        avg_fitness = get_avg_fitness(all_species[spec])
        max_fitness = max(list(map(lambda x: x['fitness'], all_species[spec])))
        min_fitness = min(list(map(lambda x: x['fitness'], all_species[spec])))
        x.append(spec)
        y_avg.append(avg_fitness)
        y_max.append(max_fitness)
        y_min.append(min_fitness)

    fig = plt.figure()

    x = np.array(x)
    y_avg = np.array(y_avg)
    y_max = np.array(y_max)
    y_min = np.array(y_min)

    plt.plot(x, y_max, label='Max')
    # plt.plot(x, y_min, label='Min')
    plt.plot(x, y_avg, label='Average')

    plt.title('Fitness by Species', fontsize=15)
    plt.xlabel('Species')
    plt.ylabel('Fitness')

    plt.legend(loc=1)
    plt.tight_layout()

    fig.savefig(out_file)
    plt.close(fig)

def get_avg_fitness(spec_data):
    if len(spec_data) == 0: return 0

    n = len(spec_data)
    s = 0
    for spec in spec_data:
        s += spec['fitness']
    return s / n

def get_species_dict(d_main):
    spec_dict = {}
    # traverse root directory, and list directories as dirs and files as files
    for root, dirs, files in os.walk(d_main):
        for file in files:
            if '.' not in file and 'Genome_' in file: # don't open other file types
                filename = os.path.join(root, file)
                species = [f for f in filename.split('/') if 'Species_' in f][0]
                spec_num = int(species.split('_')[1])

                data = parse_data(filename)
                spec_dict[spec_num] = spec_dict.get(spec_num, [])
                spec_dict[spec_num].append(data)
    return spec_dict

def get_generation_dict(d_main):
    gen_dict = {}
    # traverse root directory, and list directories as dirs and files as files
    for root, dirs, files in os.walk(d_main):
        for file in files:
            if '.' not in file and 'Genome_' in file: # don't open other file types
                filename = os.path.join(root, file)
                generation = [f for f in filename.split('/') if 'Generation_' in f][0]
                gen_num = int(generation.split('_')[1])

                data = parse_data(filename)
                gen_dict[gen_num] = gen_dict.get(gen_num, [])
                gen_dict[gen_num].append(data)
    return gen_dict

def parse_data(data_file):
    data = {}
    with open(data_file, 'r') as f:
        data = json.load(f)
    return data

if __name__ == '__main__':
    main()
