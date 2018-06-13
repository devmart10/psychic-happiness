import matplotlib
matplotlib.use('Agg')

from matplotlib import pyplot
import matplotlib.patches as mpatches
from math import cos, sin, atan
import math

from pprint import pprint as pp

class Neuron():
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.n_id = -1

    def __repr__(self):
        return 'Node %s <%s, %s>' % (self.n_id, self.x, self.y)

    def draw(self, neuron_radius):
        circle = pyplot.Circle((self.x, self.y), radius=neuron_radius, fill=False)
        pyplot.gca().add_patch(circle)


class Layer():
    def __init__(self, network, neurons, number_of_neurons, number_of_neurons_in_widest_layer):
        self.neurons_alt = neurons

        self.vertical_distance_between_layers = 6
        self.horizontal_distance_between_neurons = 2
        self.neuron_radius = 0.5
        self.number_of_neurons_in_widest_layer = number_of_neurons_in_widest_layer
        self.previous_layer = self.__get_previous_layer(network)
        self.y = self.__calculate_layer_y_position()
        self.neurons = self.__intialise_neurons(number_of_neurons)

    def __intialise_neurons(self, number_of_neurons):
        sort = sorted(self.neurons_alt)
        neurons = []
        x = self.__calculate_left_margin_so_layer_is_centered(number_of_neurons)
        for iteration in range(number_of_neurons):
            neuron = Neuron(x, self.y)
            # NEW STUFF
            neuron.n_id = int(sort[iteration])

            neurons.append(neuron)
            x += self.horizontal_distance_between_neurons
        return neurons

    def __calculate_left_margin_so_layer_is_centered(self, number_of_neurons):
        return self.horizontal_distance_between_neurons * (self.number_of_neurons_in_widest_layer - number_of_neurons) / 2

    def __calculate_layer_y_position(self):
        if self.previous_layer:
            return self.previous_layer.y + self.vertical_distance_between_layers
        else:
            return 0

    def __get_previous_layer(self, network):
        if len(network.layers) > 0:
            return network.layers[-1]
        else:
            return None

    def draw(self, layerType=0):
        sort = sorted(self.neurons_alt)
        for n_id, neuron in enumerate(self.neurons):
            neuron.draw( self.neuron_radius )

            neuron_alt = self.neurons_alt[sort[n_id]]
            if 'incoming' in neuron_alt:
                incoming = neuron_alt['incoming']
                for j, previous_layer_neuron in enumerate(self.previous_layer.neurons):
                    if j in incoming:
                        line_between_two_neurons(self.neuron_radius, neuron, previous_layer_neuron, neuron_alt['value'])
            offset_label = .3 # used to center the id number
            pyplot.text(neuron.x - offset_label, neuron.y, str(sort[n_id]), fontsize=6)

    def draw2(self, all_neurons, genes):
        sort = sorted(self.neurons_alt)
        for n_id, neuron in enumerate(self.neurons):
            neuron.draw( self.neuron_radius )

            # neuron_alt = self.neurons_alt[sort[n_id]]
            # if 'incoming' in neuron_alt:
            #     incoming = neuron_alt['incoming']
            #     for j in incoming:
            #         in_node_index = genes[j]['into']
            #         out_node_index = genes[j]['out']
            #         weight = genes[j]['weight']
            #         neuron_radius = .5
            #         pp('(in_node_index: %s, out_node_index: %s, weight: %s)' % (in_node_index, out_node_index, weight))
            #         # line_between_two_neurons(neuron_radius, all_neurons[in_node_index], all_neurons[out_node_index], weight)
            #         line_between_two_neurons(neuron_radius, neuron, previous_layer_neuron, neuron_alt['value'])

            offset_label = .3 # used to center the id number
            pyplot.text(neuron.x - offset_label, neuron.y, str(sort[n_id]), fontsize=6)

def line_between_two_neurons(neuron_radius, neuron1, neuron2, linewidth):
    # norm_width = 1 + abs(linewidth)
    norm_width = 2
    MAX_VAL = 3.0
    alpha = .1 + .9*(abs(linewidth) / MAX_VAL)

    if linewidth < 0: 
        color = (1, 0, 0, alpha)
    else: 
        color = (0, 0, 1, alpha)

    angle = 0
    if float(neuron2.y - neuron1.y) != 0:
        angle = atan((neuron2.x - neuron1.x) / float(neuron2.y - neuron1.y))

    x_adjustment = neuron_radius * sin(angle)
    y_adjustment = neuron_radius * cos(angle)

    line = pyplot.Line2D((neuron1.x - x_adjustment, neuron2.x + x_adjustment), (neuron1.y - y_adjustment, neuron2.y + y_adjustment), color=color, linewidth=norm_width)
    pyplot.gca().add_line(line)

class NeuralNetwork():
    def __init__(self, number_of_neurons_in_widest_layer, genes, data):
        self.number_of_neurons_in_widest_layer = number_of_neurons_in_widest_layer
        self.layers = []
        self.layertype = 0
        self.genes = genes
        self.data = data

    def add_layer(self, neurons ):
        layer = Layer(self, neurons, len(neurons), self.number_of_neurons_in_widest_layer)
        self.layers.append(layer)

    def draw(self, filename, info):
        all_neurons = []
        for layer in self.layers:
            all_neurons.extend(layer.neurons)
        # pp(all_neurons)

        fig = pyplot.figure(figsize=(8, 6))
        for i in range( len(self.layers) ):
            layer = self.layers[i]
            if i == len(self.layers)-1:
                i = -1
            # layer.draw( i )
            layer.draw2(all_neurons, self.genes)


        for gene in self.genes:
            in_node_index = gene['into']
            out_node_index = gene['out']
            weight = gene['weight']
            neuron_radius = .5
            # line_between_two_neurons(neuron_radius, getNeuronGivenAll(all_neurons, in_node_index), getNeuronGivenAll(all_neurons, out_node_index), weight)
            line_between_two_neurons(neuron_radius, getNeuronGivenAll(all_neurons, out_node_index), getNeuronGivenAll(all_neurons, in_node_index), weight)

        pyplot.axis('scaled')
        pyplot.axis('off')

        pyplot.title( 'Network Architecture', fontsize=15 )

        blue_patch = mpatches.Patch(color='b', label='Positive Weight')
        red_patch = mpatches.Patch(color='r', label='Negative Weight')

        textstr = 'Generation: %2d\nSpecies:      %2d\nGenome:     %2d\n' % (info)
        textstr += '\nFitness:  %3.2f' % (self.data['fitness'])
        props = dict(boxstyle='round', facecolor='grey', alpha=0.2)
        # place a text box in upper left in axes coords
        pyplot.gca().text(0.02, .8, textstr, transform=pyplot.gca().transAxes, fontsize=9,
                verticalalignment='top', bbox=props)

        pyplot.legend(handles=[blue_patch, red_patch], loc=2)
        pyplot.tight_layout()
        
        fig.savefig(filename)
        pyplot.close(fig)

def getNeuronGivenAll(all_neurons, n_id):
    for neuron in all_neurons:
        if neuron.n_id == n_id:
            return neuron

class DrawNN():
    def __init__( self, neural_network, genes, data ):
        self.neural_network = neural_network
        self.genes = genes
        self.data = data

    def draw( self, filename, info):
        widest_layer = max( list(map(len, self.neural_network)) )
        network = NeuralNetwork( widest_layer, self.genes, self.data )
        for l in self.neural_network:
            network.add_layer(l)
        network.draw(filename, info)
