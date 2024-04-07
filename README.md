# Project Summary

SuperLife Insurance, one of Lumaria’s major life insurance carriers, aims to improve expected mortality for its policyholders and is looking to implement targeted health incentive programs to achieve its goal. 

Target objectives include improvements in Lumarian mortality rates through incentivising healthy behavior and long-term uplift in SuperLife sales. This will be measured through:
  - Mortality rates
  - Customer Satisfaction and renewal rates
  - Sales and Financial sustainability
  - Policy uptake

# Program Design

The health incentives offered by the program are:
 - Smoking cessation: Targeted support from counselling as well as access to nicotine replacement therapies
 - Cancer prevention initiatives: Aims to help policyholders prevent one of the leading causes of death. 
 - Gender-specific health screenings: Aims to leverage early detection of diseases to significantly boost health outcomes

Our evaluation strategy aims to capture both short-term and long-term outcomes (5 years and 20 years respectively). 

In the short term, there will be a focus on early indicators on the efficacy of the program, including participation rates and additional policy uptake following the introduction of the policy. Adjustments will be made to meet the evolving needs of the Lumarian population. Over the long term, we aim to assess the impact of interventions on mortality changes in the policyholder population. In particular, decreases in smoking rates may be a key indicator of the long-term success of the smoking cessation program. 

Logistics wise, the implementation of our program will be rolled out across all six regions of Lumaria. No variation in pricing or assumptions will be applied across the differing regions, due to financial consistency between all regions. Regarding distribution channels, we aim to increase outreach through a wider range of agents across Lumaria. 

# Pricing 

To model the effects of the interventions on the last 20 years (i.e. since 2004), a model was built that would simulate how each policyholder’s outcome would change when the initiatives were introduced. Under this model, SuperLife absorbs all expenses associated with the initiatives. 

Premiums for all policyholders were estimated using the policyholder’s policy type and their own mortality rates derived from their personal attributes. 

Once premiums were estimated, the first part of the model simulated policyholders that were known to have died from 2004 onwards. On the year of their death, the model would simulate their probability of dying based on their time spent in the policy. If they lived, they would move on to the next year and have a chance of lapsing or dying again with the same adjusted mortality rate. 

The second part of the model simulated new policyholders that bought a policy as a result of the initiatives. At each year from 2004 onwards new policyholders would be simulated, their attributes generated from empirical distributions from the inforce data, including face amount and premium. The model then simulates each policyholder’s probability of lapse and death.

In both parts of the model, premiums and expenses are collected at the start of the year and liabilities added upon a policyholder’s death. These are then summed to give the final revenue, expense and liabilities figures.

Policyholder premiums were determined using the equivalence principle, by considering the present value of future expected benefit payments. The collection of premiums for the two policy types offered by SuperLife were as follows:
T20: 20-year level term - annual premium payments at the beginning of each year for the duration of the policy or, until year of death.

SPWL: Single Premium Whole Life - single premium paid at the issue date.

# Costs and Savings

Costs of Program Implementation

| Smoking Cessation Programs  | Cancer Prevention Initiatives | Health Screenings |
| ------------- | ------------- | ------------- |
| 2177.5 Č per particpant  | 52.5 Č per participant per year  | 217.5 Č per participant per year |

Mortality savings: Comparing the same set of inforce policies with and without the effect of the interventions, we found that on average the implementation of our plan would have saved around 6750 lives, or close to 17% of policyholders who would have otherwise died.

Economic Value: The economic value of the proposed program is approximately 190B Č based on projected profit across the 20 years. 

Premium Impact Justification: Given the savings realised from reduced mortality, costs of implementation will not be reflected in any changes to premium amounts. This is to allow for the target objective of improving product marketability and competitiveness whilst still ensuring SuperLife’s long-term financial sustainability. 

# Assumptions 
Economic Assumptions: 
 - Discounting factor used is real interest rate of given year
 - The face amount of each policy is deemed to be the real benefit amount in the year that the policyholder dies should that occur.
 - Initiative costs as given by SuperLife are assumed to be in terms of today’s money and so are not discounted.

Mortality Assumptions:
 - Mortality data from external countries such as the USA and Australia have been used as comparable measures of mortality to Lumaria.
       - The relationships within categories including gender and smoking status are assumed to be consistent between countries.
 - The population of Lumaria is composed of an equal split between male and female.
 - For smokers, it is assumed that the split of smokers and non-smokers is constant between the male and female population, with 18% of smokers and 82% non smokers.
 - The demographic impacts on mortality are assumed to be stable over time - i.e. the relationship between male and female mortality, and smoker/non-smoker mortality does not change over the years, with the relationship based on most recent available data within the policy timeline.
 - The proportion of each underwriting status in the population is assumed to reflect the proportion within the in-force dataset.
 - The age distribution of incoming policy holders would be consistent with those already holding a policy.

Lapse Assumptions:
 - Lapse probabilities are taken from the inforce data
 - The empirical probabilities are assumed to contain sufficient information about the external influences (e.g. economic) in that year contributing to the lapses.

Expense Assumptions:
 - The only expenses considered in our analysis are those of the health initiatives. Of the three chosen, two (Cancer Prevention Initiatives and Heart Health Screenings) are yearly expenses applied to each policyholder. The yearly costs arise as so: 
     - A new initiative under the Cancer Prevention Initiatives is rolled out each year
     - Screenings under the Heart Health Screenings program are done once a year
     - The last initiative (Smoking Cessation Programs) is a one-off expense applied only to smoker policyholders in the year they enter the program.
     - All policyholders participate in the initiatives from the moment their policy is in force.

Model Assumptions: 
 - The inforce dataset is taken to be a sufficient sample of the population for the purposes of drawing demographic statistics for the simulation of new policyholders.
 - The mortality table is also taken to be accurate as a baseline for all lives in force.
 - In a given year, the timeline for a claim is as follows :
      1) A policyholder has their birthday at the start of the year.
      2) Their policy is purchased/renewed immediately after their birthday.
           a) The policyholder pays the premium and SuperLife pays the expenses for the relevant initiatives.
      3) Lapses occur anytime between policy purchase/renewal and the end of the year.
      4) Death (if it happens) occurs at the end of the year.
 - The interventions only have a positive effect on mortality, such that any policyholder that stayed alive until 2023 or the lapse of their policy will remain so in the model.
       - As such, policyholders who either stayed alive or lapsed are essentially unaffected mortality-wise and will not incur death in the model.
       - This extends to policyholders which were known to die at a certain year; they will remain alive until at least that year.
       - Their disease will only affect their mortality from the year of death onwards.
   
# Risks and Mitigation

Unexpected incentive engagement: Ensure sufficient marketing of new program incentives, throughout all distribution channels. Adjust product throughout for feedback. 

Cost Overruns: Establish strict budget control, with budget contingencies for unforeseen expenses. Having a detailed project plan before implementation can also mitigate scope creep and budget overruns. 

Cybersecurity Risks: Establish strict data security policies and procedures with data only released to employees on a “need to know” basis. Data should also be encrypted, with additional layers of security such as anti-virus and firewalls installed.

Insurance Risk: Do sufficient stress testing for adverse conditions. Hold sufficient reserves to account for insurance risk. Consult with reinsurance firms to mitigate the risk of SuperLife being unable to pay its liabilities.

Legal Considerations: In the transition process, consult with external lawyers and maintain an internal legal team to protect the company against any breaches of the law. 

# Sensitivity Analysis

# Data sources and Limitations:






# Actuarial Theory and Practice A @ UNSW

_"Tell me and I forget. Teach me and I remember. Involve me and I learn" - Benjamin Franklin_

---

### Congrats on completing the [2024 SOA Research Challenge](https://www.soa.org/research/opportunities/2024-student-research-case-study-challenge/)!

>Now it's time to build your own website to showcase your work.  
>To create a website on GitHub Pages to showcase your work is very easy.

This is written in markdown language. 
>
* Click [link](https://classroom.github.com/a/biNKOeX_) to accept your group assignment.

#### Follow the [guide doc](doc1.pdf) to submit your work. 

When you finish the task, please paste your link to the Excel [sheet](https://unsw-my.sharepoint.com/:x:/g/personal/z5096423_ad_unsw_edu_au/ETIxmQ6pESRHoHPt-PUleR4BuN0_ghByf7TsfSfgDaBhVg?rtime=GAd2OFNM3Eg) for Peer Feedback
---
>Be creative! Feel free to link to embed your [data](2024-srcsc-superlife-inforce-dataset-part1.csv), [code](sample-data-clean.ipynb), [image](unsw.png) here

More information on GitHub Pages can be found [here](https://pages.github.com/)
![](Actuarial.gif)
