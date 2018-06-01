import matplotlib
matplotlib.use('Agg')

from matplotlib import pyplot
import matplotlib.patches as mpatches
from math import cos, sin, atan

from pprint import pprint as pp

class Neuron():
    def __init__(self, x, y):
        self.x = x
        self.y = y

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
        neurons = []
        x = self.__calculate_left_margin_so_layer_is_centered(number_of_neurons)
        for iteration in range(number_of_neurons):
            neuron = Neuron(x, self.y)
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

    def __line_between_two_neurons(self, neuron1, neuron2, linewidth):
        angle = atan((neuron2.x - neuron1.x) / float(neuron2.y - neuron1.y))
        x_adjustment = self.neuron_radius * sin(angle)
        y_adjustment = self.neuron_radius * cos(angle)
        if linewidth < 0: 
            color = 'r' 
        else: 
            color = 'b'
        norm_width = 1 + abs(linewidth) / 10
        line = pyplot.Line2D((neuron1.x - x_adjustment, neuron2.x + x_adjustment), (neuron1.y - y_adjustment, neuron2.y + y_adjustment), color=color, linewidth=norm_width)
        pyplot.gca().add_line(line)

    def draw(self, layerType=0):
        sort = sorted(self.neurons_alt)
        for n_id, neuron in enumerate(self.neurons):
            neuron.draw( self.neuron_radius )

            neuron_alt = self.neurons_alt[sort[n_id]]
            if 'incoming' in neuron_alt:
                incoming = neuron_alt['incoming']
                for j, previous_layer_neuron in enumerate(self.previous_layer.neurons):
                    if j in incoming:
                        self.__line_between_two_neurons(neuron, previous_layer_neuron, neuron_alt['value'])
            offset_label = .3 # used to center the id number
            pyplot.text(neuron.x - offset_label, neuron.y, str(sort[n_id]), fontsize=6)

class NeuralNetwork():
    def __init__(self, number_of_neurons_in_widest_layer):
        self.number_of_neurons_in_widest_layer = number_of_neurons_in_widest_layer
        self.layers = []
        self.layertype = 0

    def add_layer(self, neurons ):
        layer = Layer(self, neurons, len(neurons), self.number_of_neurons_in_widest_layer)
        self.layers.append(layer)

    def draw(self, filename):
        fig = pyplot.figure(figsize=(8, 6))
        for i in range( len(self.layers) ):
            layer = self.layers[i]
            if i == len(self.layers)-1:
                i = -1
            layer.draw( i )
        pyplot.axis('scaled')
        pyplot.axis('off')
        pyplot.title( 'Neural Network architecture', fontsize=15 )

        blue_patch = mpatches.Patch(color='b', label='Positive Weight')
        red_patch = mpatches.Patch(color='r', label='Negative Weight')
        pyplot.legend(handles=[blue_patch, red_patch], loc=2)
        pyplot.tight_layout()
        
        fig.savefig(filename)

class DrawNN():
    def __init__( self, neural_network ):
        self.neural_network = neural_network

    def draw( self, filename ):
        widest_layer = max( list(map(len, self.neural_network)) )
        network = NeuralNetwork( widest_layer )
        for l in self.neural_network:
            network.add_layer(l)
        network.draw(filename)
