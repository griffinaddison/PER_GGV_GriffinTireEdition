Our tires:
Hoosier R25B 18.0 x 7.5 - 10
Meaning:
18 inch wheel diameter
10 inch rim diameter
7 inch rim width (not sure what 7.5 is, 7 is measured)

Excerpts from my (Sam P) convo with Josh on current analysis process / CALSPAN data:

honestly it's not super useful
they test on a ultra high friction belt

so we're talking 2+ COF
when realistically you only get 1.3 max on asphalt
so I had to do some data scaling to approximately get the friction coefficient we expect on asphalt
but I'm not sure how much of that screws with the SR / SA force curves
i've uploaded all the raw data on the drive under resources
I have a matlab script that extracts relevant data
it's in the Vehicle Dynamics github
under Vehicle-Dynamics/model_sim/resources/data/tires
there are two testing runs for our tires along with a process.m script
it's pretty easy to plot SR / SA response curves from that
I then load the processed data into a fitting tool
Vehicle-Dynamics/model_sim/plugins/MF_Tire_GUI_V2a
to fit the pace formula
But fitting SA and SR separately causes unrealistic friction forces for combined SA / SR action
like you could have 1.3 long coef and 1.3 lat coef and get a total COF of 1.8
so I then take the predicted force output and normalize it so it's never bigger than 1.3 (i could maybe adjust this a bit higher)
so after all that I'm not really sure how much it matches actual road conditions
fitting the pace formula is really involved and i don't have the time to do a better job of it at the moment but that's the process i've used
