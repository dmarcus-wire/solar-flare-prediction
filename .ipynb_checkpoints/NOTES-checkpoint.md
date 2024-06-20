# Solar Flare Prediction

Intent for this repo is to configure the Red Hat OpenShift environment and ML tools needed for data scientists to prepare data and code ML system to predict solar flares.

## Recent Events

![image](./images/x6.37-02-22-2024-solar-flare.jpg)

On Feburary 22, 2024, three top-tier X-class solar flares launched off the sun between Wednesday and Thursday. 

![image](./images/solar-flare-1-and-2.png)
The first two occurred seven hours apart (02-21-24 18:07 EST and 02-22-24 01:32 EST), coming in at X1.9 and X1.6 magnitude respectively. 

![image](./images/solar-flare-3.png)
The third, the most powerful of the current 11-year “solar cycle,” ranked an impressive X6.3 (02-23-24 1734 EST). [source](https://www.washingtonpost.com/weather/2024/02/22/solar-flares-cycle-xclass-radio-att/), [source](https://www.esa.int/Space_Safety/Space_weather/Sun_fires_off_largest_flare_of_current_solar_cycle), [source](https://www.swpc.noaa.gov/news/two-major-solar-flares-effects-cellular-networks-unlikely) and [source](https://www.swpc.noaa.gov/news/strongest-flare-current-solar-cycle).

All three of the X-class solar flares disrupted shortwave radio communications on Earth.

The third solar flare, which ranked an X6.37 in magnitude. Notice the fuzzy appearance on the sensor. It was being bombarded by photons and high-energy electrons associated with the flare. This results in a “wide area blackout of [high frequency] radio communication, [and] loss of radio contact for about an hour on sunlit side of Earth.” [source](https://www.washingtonpost.com/weather/2024/02/22/solar-flares-cycle-xclass-radio-att/)

[source](https://www.washingtonpost.com/weather/2024/02/22/solar-flares-cycle-xclass-radio-att/)

![image](./images/noaa-swpc-02-22-2024.jpg)

## Background

![image](./images/modified-zurich-sunspot-classification.png)

Solar flares, or bursts of radiation, are ranked on a scale that goes from A, B and C to M and X, in increasing order of intensity. They usually originate from sunspots, or bruiselike discolorations on the surface of the sun. The more sunspots, the more opportunities for solar flares.

Solar flares and accompanying coronal mass ejections, or CMEs, can influence “space weather” across the solar system, and even here on Earth. 

CMEs are slower shock waves of magnetic energy from the sun. Flares can reach Earth in minutes, but CMEs usually take at least a day.

## Look ahead

“The level of activity here is the biggest it’s been since about 20 years, since about 2003,” said Mark Miesch, a member of the solar modeling team at NOAA’s Space Weather Prediction Center.

The Halloween Storms of 2003 brought dazzling green, red and purple aurora all the way to California, Texas, Florida and even Australia. They also disrupted more than half of all spacecraft orbiting Earth, damaged a satellite beyond repair and created communication issues for airlines and research groups in Antarctica.

The sun is currently in its 25th solar cycle since observations in the 1700s.

Almost halfway through its current solar cycle, the sun is expected to reach its peak activity between January and October 2024, but activity will probably still be high into 2025 or maybe 2026, according to Space Weather Prediction Center models. [source](https://www.washingtonpost.com/climate-environment/2024/01/14/solar-max-sun-activity-storms-aurora/)

Goal: Demonstrate platform resources applied to GONG data fetch and ETL, ML experimentation and distributed training, and ML deployment on OpenShift. 

# Data
source: National Solar Observatory Global Oscillation Network Group
requested: https://gong2.nso.edu/archive/patch.pl?menutype=s
specific range: https://nispdata.nso.edu/ftp/oQR/zqa/202402/

| Location | Relevant Sensor Data | Product* | Date Range | Data Link | Image Count |
|---|---|---|---|
| Learmonth, Australia | [x] | [x] | 2024-02-01:2024-02-29 | | 1325 |
| Udaipur, India | [x] | [x] | 2024-02-01:2024-02-29 | [data](https://nispdata.nso.edu/ftp/oQR/zqa/202402/) | 938 |
| El Teide, Spain | [x] | [x] | 2024-02-01:2024-02-29 | [data] | 1336 |
| Cerro Tololo, Chile | | |
| Big Bear, California | | |
| Mauna Loa, Hawaii | | |
| TE Engineering site, Boulder, Colorado | | |
| TC Engineering site, Boulder, Colorado | | |

*Product == Average Magnetogram (Zero Point Corrected)