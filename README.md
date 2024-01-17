# ComThetrainline

<!-- vim-markdown-toc GFM -->

* [Prerequisites](#prerequisites)
* [Usage](#usage)
* [Testing](#testing)

<!-- vim-markdown-toc -->

## Prerequisites

* Ruby v3

Optional:

* [asdf](https://asdf-vm.com/) (as this repo lists ruby-3.1.1 as its local ruby
  version)


## Usage

To run this application locally, first run the server binary on port 9000:

    ./server

Next, run the ruby file in another terminal:

    ruby ./lib/com_thetrainline.rb

This is not a CLI, instead the class method defined is called in the `main.rb`
file. As such, it does not accept any user input.


##  Testing

Tests are written in rspec and can be run with the following command:

    rspec
