Neural Nets
============

run the tests by doing a `bundle exec rake`

This repository aims to classify sentences by character frequency into languages based on passages in the bible.

The training set is all chapters of Matthew and Acts in Norwegian, English, Polish, Swedish, German, and Finnish.

There are two classes and a module in this repo and are:

* Language - This takes a language training file, parses it and calculates an array of character frequencies built up using a hash.
* Tokenizer - This is where the tokenization is accomplished for each text blob
* Network - This interfaces with ruby-fann to train a neural network

To build a network built up on Language data one would do as follows

```ruby
english = Language.new('English.txt', 'English')
network_of_english = Network.new([english])
network_of_english.train!

network_of_english.run('The quick brown fox') #=> english
```