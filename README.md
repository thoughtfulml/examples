Neural Nets
============


Fundamentally neural nets are a simple idea:

Take information that we 'believe' to map to a set of outputs. 

There are some major pieces of a neural net and they are:

* Network: These are defined by the syntax I-H-H-O where I is the input layer, H is a hidden layer, and O is the output layer. So if we have 26 inputs 6 outputs and 12 hidden neurons we would notate that as 26-12-6.
* Neuron: Neurons are dumb actors that take multiple inputs and output based on an activation function.
* Algorithm: There are many algorithms for training a network we will use the RProp algorithm since it is fast and usable.
* Input Data: In this case it will be a document
* Output data: Output will be a language classification



