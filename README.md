# citation_explorer

This Matlab function uses Europe PubMed Central's [RESTful web service](https://europepmc.org/RestfulWebService#sort) to extract references or citations from a given "seed" paper and recursively find reference/citations within those. The relevant papers at each level can be crudely assessed by counting how many times they appear.

## Usage 

 The first argument is a search string for the initial paper, the title generally works well.
 
 Other arguments use name-value pairs and are :
 
   - `'searchtype'`: Cell of strings, default is `{'reference' 'citation'}`.
   This input is used to indicate the search direction at each level of
   the recursion. Use 'reference' to search the references in all
   papers at a given level. Use 'citation' to search which papers cited
   each of the papers at a given level. The first element indicates the search
   done on the initial seed paper. The default value thus searches all
   references in the initial paper, and then all the articles citing each
   of these references. This combination is useful to search for relevant
   recent papers on the same topic. Only two levels are recommended for
   most cases: 3 levels leads to a very large amount of searches as there
   are no optimizations yet.
   
   - `'disp'`: Integer, default is 30. This parameter indicates how many of
   the found papers at the last level should be displayed, ordered in
   descending order of number of appearances in the level. With the
   default 'searchtype', the first paper in the list should be the
   original paper.
   
   
The function returns a table containing metadata about all the retrieved
papers. The field `link_id` stores the ID of the paper that linked to the paper, which 
could be useful for constructing graphs afterwards. The field `level` indicates at
which level of the recursion the paper was retrieved.
   
## Example

```matlab
out = citation_explorer('What makes a reach movement effortful',...
    'searchtype',{'reference' 'citation'},...
    'disp',30);
```

Command-line output (these are papers that cite the same papers cited by the seed article):

| N_appearences  | N_citations | Paper info |
| --- | --- | --- |
| 28 | 3 | Morel P, Ulbrich P, Gail A. (2017) What makes a reach movement effortful? Physical effort discounting supports common minimization principles in decision making and motor control. | 
| 11 | 11 | Shadmehr R, Huang HJ, Ahmed AA. (2016) A Representation of Effort in Decision-Making and Motor Control. | 
| 8 | 0 | Pessiglione M, Vinckier F, Bouret S, Dau (2017) Why not try harder? Computational approach to motivation deficits in neuro-psychiatric diseases. | 
| 7 | 26 | Rigoux L, Guigon E. (2012) A model of reward- and effort-based optimal decision making and motor control. | 
| 7 | 1 | Wang C, Xiao Y, Burdet E, Gordon J, Schw (2016) The duration of reaching movement is longer than predicted by minimum variance. | 
| 7 | 1 | Cos I. (2017) Perceived effort for motor control and decision-making. | 
| 6 | 1 | Diamond JS, Wolpert DM, Flanagan JR. (2017) Rapid target foraging with reach or gaze: The hand looks further ahead than the eye. | 
| 6 | 0 | Peternel L, Sigaud O, Babic J. (2017) Unifying Speed-Accuracy Trade-Off and Cost-Benefit Trade-Off in Human Reaching Movements. | 
| 5 | 12 | Klein-Flugge MC, Kennerley SW, Saraiva A (2015) Behavioral modeling of human choices reveals dissociable effects of physical effort and temporal delay on reward devaluation. | 
| 5 | 11 | Apps MA, Grima LL, Manohar S, Husain M. (2015) The role of cognitive effort in subjective reward devaluation and risky decision-making. | 
| 5 | 0 | Kudo N, Choi K, Kagawa T, Uno Y. (2016) Whole-Body Reaching Movements Formulated by Minimum Muscle-Tension Change Criterion. | 
| 5 | 9 | Schwartz AB. (2016) Movement: How the Brain Communicates with the World. | 
| 5 | 1 | Huh D, Sejnowski TJ. (2016) Conservation law for self-paced movements. | 
| 5 | 0 | Bakker RS, Weijer RHA, van Beers RJ, Sel (2017) Decisions in motion: passive body acceleration modulates hand choice. | 
| 5 | 3 | Dhawale AK, Smith MA, Olveczky BP. (2017) The Role of Variability in Motor Learning. | 
| 5 | 2 | Vassena E, Deraeve J, Alexander WH. (2017) Predicting Motivation: Computational Models of PFC Can Explain Neural Coding of Motivation and Effort-based Decision-making in Health and Disease. | 
| 5 | 1 | Le Heron C, Apps MAJ, Husain M. (2017) The anatomy of apathy: A neurocognitive framework for amotivated behaviour. | 
| 4 | 9 | Wang W, Dounskaia N. (2012) Load emphasizes muscle effort minimization during selection of arm movement direction. | 
| 4 | 29 | Fervaha G, Foussias G, Agid O, Remington (2013) Neural substrates underlying effort computation in schizophrenia. | 
| 4 | 25 | Apps MA, Ramnani N. (2014) The anterior cingulate gyrus signals the net value of others' rewards. | 
| 4 | 15 | Verguts T, Vassena E, Silvetti M. (2015) Adaptive effort investment in cognitive and physical tasks: a neurocomputational model. | 
| 4 | 19 | Lepora NF, Pezzulo G. (2015) Embodied choice: how action influences perceptual decision making. | 
| 4 | 1 | Taniai Y, Nishii J. (2015) Optimality of Upper-Arm Reaching Trajectories Based on the Expected Value of the Metabolic Energy Cost. | 
| 4 | 22 | Manohar SG, Chong TT, Apps MA, Batla A,  (2015) Reward Pays the Cost of Noise Reduction in Motor and Cognitive Control. | 
| 4 | 14 | Massar SA, Libedinsky C, Weiyan C, Huett (2015) Separate and overlapping brain areas encode subjective value during delay and effort discounting. | 
| 4 | 18 | Scholl J, Kolling N, Nelissen N, Wittman (2015) The Good, the Bad, and the Irrelevant: Neural Mechanisms of Learning Real and Hypothetical Rewards and Effort. | 
| 4 | 2 | Bakker RS, Selen LP, Medendorp WP. (2015) Stability of Phase Relationships While Coordinating Arm Reaches with Whole Body Motion. | 
| 4 | 3 | Dounskaia N, Shimansky Y. (2016) Strategy of arm movement control is determined by minimization of neural effort for joint coordination. | 
| 4 | 2 | Vu VH, Isableu B, Berret B. (2016) On the nature of motor planning variables during arm pointing movement: Compositeness and speed dependence. | 
| 4 | 13 | Klein-Flugge MC, Kennerley SW, Friston K (2016) Neural Signatures of Value Comparison in Human Cingulate Cortex during Decisions Requiring an Effort-Reward Trade-off. | 
