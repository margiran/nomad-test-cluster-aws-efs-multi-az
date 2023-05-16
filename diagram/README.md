# Diagram as code with Diagrams

[Diagrams](https://diagrams.mingrammer.com/) lets you draw the cloud system architecture in Python code.

## Pre-requisites

* You must have [python](https://www.python.org/downloads/) 3.6 or higher installed on your computer. 

* diagrams uses [Graphviz](https://www.graphviz.org/) to render the diagram, so you need to [install Graphviz](https://graphviz.gitlab.io/download/) to use diagrams. After installing graphviz (or already have it), install the diagrams.

<sub>
macOS users can download the Graphviz via `brew install graphviz` if you're using Homebrew. Similarly, Windows users with Chocolatey installed can run `choco install graphviz`.
</sub>

## Installation

using pip(pip3)
```
pip install diagrams
```

## Generate the diagram

```
python simple_nomad_cluster.py
```
