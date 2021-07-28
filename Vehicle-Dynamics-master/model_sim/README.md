# VEHICLE DYNAMICS MODEL SIMULATION
This project contains code for analyzing testing data and comparing different design tradeoffs for the Penn Electric Racing Formula SAE team. It is intended to be accurate, modular, and relatively easy to use for even an inexperienced programmer.

** NOTE THAT ANALYZING DATA NEEDS SEPARATE DOWNLOAD. SEE INSTRUCTIONS BELOW. **
## Directory structure
`model`: Contains all the different components that come together to model a car's dynamics, as well as various controller for the car model.

`sim`: Generally takes in a model and actually runs a simulation, be it a normal x-y plane sim, lap sim, etc.

`vis`: Contains core visualization code for rendering simulations and models.

`study`: Various studies comparing different simulations, investigating real-world data, or a mix of both. Also serves as a collection of examples and use cases.

`utils`: Utility files and functions.

`resources`: Any testing data, external documentation, datasheets, etc. used for a component of the simulation.

** DATA DIRECTORY IS TOO LARGE TO HOST ON GITHUB. PLEASE DOWNLOAD AND UNPACK SEPARATELY FROM THE DRIVE (COMMON RESOURCES/VEHICLE DYNAMICS DATA REPO). PLACE UNDER RESOURCES. **

`plugins`: Third party plugins.

## Examples
For both basic examples and actual studies, see the study directory.

FIRST RUN SETUP.M (just call `setup` in the root directory)

Some good examples to check out are `inspect_car`, `data_sim_comparison`, `example_slalom`, and `mass_sweep`.
