% LANDSAT 5 
clc;clear;
fname = 'LT05_L1TP_002067_19950511_20200913_02_T1_MTL.json';
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

%% 1995
meuretangle = [2352,915,6502-2352,6203-915];
%BIV = double(imread('LT05_L2SP_214066_19890928_20200916_02_T1_SR_B4.TIF'));
B4 = double(imcrop(imread('LT05_L1TP_002067_19950511_20200913_02_T1_B4.TIF'),meuretangle));
B3 = double(imcrop(imread('LT05_L1TP_002067_19950511_20200913_02_T1_B3.TIF'),meuretangle));
B6 = double(imcrop(imread('LT05_L1TP_002067_19950511_20200913_02_T1_B6.TIF'),meuretangle));


%CALIBRAÇÃO RADIOMÉTRICA E REFLECTÂNCIA ESPECTRAL
%Calibração Radiométrica
a_BAND3 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_MIN_MAX_RADIANCE.RADIANCE_MINIMUM_BAND_3);
a_BAND4 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_MIN_MAX_RADIANCE.RADIANCE_MINIMUM_BAND_4);
a_BAND6 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_MIN_MAX_RADIANCE.RADIANCE_MINIMUM_BAND_6); 
b_BAND3 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_MIN_MAX_RADIANCE.RADIANCE_MAXIMUM_BAND_3);
b_BAND4 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_MIN_MAX_RADIANCE.RADIANCE_MAXIMUM_BAND_4);
b_BAND6 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_MIN_MAX_RADIANCE.RADIANCE_MAXIMUM_BAND_6);


%L_toa = ai + ((bi-ai)/255)*ND
L_toaB3 = a_BAND3+((b_BAND3-a_BAND3)/255)*B3;
L_toaB4 =  a_BAND4+((b_BAND4-a_BAND4)/255)*B4;
L_toaB6 =  a_BAND6+((b_BAND6-a_BAND6)/255)*B6;

%Reflectância monocromática de cada banda
%Irradiação solar espectral, de cada banda, no topo da atmosfera (ki)
%DATE_ACQUIRED = 2008 - 11 -01;
DSA = 306;
SUN_ELEVATION = str2double(val.LANDSAT_METADATA_FILE.IMAGE_ATTRIBUTES.SUN_ELEVATION);
EARTH_SUN_DISTANCE = val.LANDSAT_METADATA_FILE.IMAGE_ATTRIBUTES.EARTH_SUN_DISTANCE;
ki_B3 = 1536;
ki_B4 = 1031;
Z = ((pi/2) -  SUN_ELEVATION/2*pi);
d = 1 + 0.033*cos(DSA*2*pi/365);
%R_toa = (pi*L_toa)/(Ki*COS(Z)*d)
R_B3 = (pi.*L_toaB3)./(ki_B3*cos(Z)*d);
R_B4 = (pi.*L_toaB4)./(ki_B4*cos(Z)*d);

NDVI = (R_B4 - R_B3)./(R_B4 + R_B3);
figure;imshow(NDVI,[])
colormap(jet)
colorbar

L  = 0.5;

SAVI = ((1 + L).*(R_B4 - R_B3))./( L + R_B4 + R_B3);
%figure; imshow(SAVI,[0 1])

IAF  = - (log((0.69 - SAVI)./0.59)./0.91);
%imshow(IAF,[0 1])
IAF = real(IAF); % verificar


EmissividadeNB = 0.97 - 0.0033*IAF;
%imshow(EmissividadeNB,[])

%TEMPERATURA DE SUPERFICIE
K1 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_THERMAL_CONSTANTS.K1_CONSTANT_BAND_6); 
K2 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_THERMAL_CONSTANTS.K2_CONSTANT_BAND_6);
T_s = (K2./log(((EmissividadeNB*K1)./L_toaB6)+1))-273.15;
figure;imshow(T_s,[])
colormap(jet)
colorbar