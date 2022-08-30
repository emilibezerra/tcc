% LANDSAT 8 
clc;clear;
fname = 'LC08_L1TP_002067_20210923_20211003_02_T1_MTL.json';
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

%% 2021
%meuretangle = [2036,1586,6194-2036,6678-1586];
%BIV = double(imcrop(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B5.TIF'),meuretangle));
%BV = double(imcrop(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B4.TIF'),meuretangle));
%B_INF = double(imcrop(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B10.TIF'),meuretangle));

BV = double(imread('TESTE_B4.TIF'));
BIV = double(imread('TESTE_B5.TIF'));
B_INF = double(imread('TESTE_B10.TIF'));


%BV(find(BV==0))= mean(BV(:));
%BIV(find(BIV==0))= mean(BIV(:));
%B_INF(find(B_INF==0))= mean(B_INF(:));

q_cal10 = B_INF./1;
q_cal4 = BV./1;
q_cal5 = BIV./1;

%ML:
RADIANCE_MULT_BAND_10 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_RADIOMETRIC_RESCALING.RADIANCE_MULT_BAND_10);

%AL:
RADIANCE_ADD_BAND_10 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_RADIOMETRIC_RESCALING.RADIANCE_ADD_BAND_10);

%CALIBRAÇÃO RADIOMÉTRICA E REFLECTÂNCIA ESPECTRAL
%Calibração Radiométrica
%BANDA 10:
L_TOA10 = (RADIANCE_MULT_BAND_10.*q_cal10)+RADIANCE_ADD_BAND_10;

%Reflectância monocromática de cada banda
DATE_ACQUIRED = 2019-10-17;
DSA = 290;
SUN_ELEVATION = str2double(val.LANDSAT_METADATA_FILE.IMAGE_ATTRIBUTES.SUN_ELEVATION);
EARTH_SUN_DISTANCE = str2double(val.LANDSAT_METADATA_FILE.IMAGE_ATTRIBUTES.EARTH_SUN_DISTANCE);
Z = ((pi/2) - SUN_ELEVATION/2*pi);
%MP:
REFLECTANCE_MULT_BAND_4 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_RADIOMETRIC_RESCALING.REFLECTANCE_MULT_BAND_4);
REFLECTANCE_MULT_BAND_5 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_RADIOMETRIC_RESCALING.REFLECTANCE_MULT_BAND_5);
%AP:

REFLECTANCE_ADD_BAND_4 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_RADIOMETRIC_RESCALING.REFLECTANCE_ADD_BAND_4);
REFLECTANCE_ADD_BAND_5 = str2double(val.LANDSAT_METADATA_FILE.LEVEL1_RADIOMETRIC_RESCALING.REFLECTANCE_ADD_BAND_5);
%B4
R_B4 = ((REFLECTANCE_MULT_BAND_4.*q_cal4)+REFLECTANCE_ADD_BAND_4)./(cos(Z).*(1/EARTH_SUN_DISTANCE.^2));
%B5
R_B5 = ((REFLECTANCE_MULT_BAND_5.*q_cal5)+REFLECTANCE_ADD_BAND_5)./(cos(Z).*(1/EARTH_SUN_DISTANCE.^2));

%ÍNDICE DE VEGETAÇÃO DE DIFERENÇA NORMALIZADA (NDVI)
NDVI = (R_B5 - R_B4)./(R_B5 + R_B4);
NDVI(find(NDVI==0))= NaN;
figure;imshow(NDVI,[0 1])
colormap(jet)
colorbar


%saveas(gcf,'NDVI','png');
%close all

%TEMPERATURA DE SUPERFICIE
L  = 0.5;
SAVI = (1 + L)*(R_B5 - R_B4)./( L + R_B5 + R_B4);
%figure; imshow(SAVI,[0 1])

IAF  =  -(log((0.69 - SAVI)./0.59)./0.91);
%imshow(IAF,[0 1])
IAF = real(IAF); % verificar

EmissividadeNB = 0.97 - 0.0033*IAF;
%imshow(EmissividadeNB,[])

%Temperatura de Superfície
K1_CONSTANT_BAND_10= str2double(val.LANDSAT_METADATA_FILE.LEVEL1_THERMAL_CONSTANTS.K1_CONSTANT_BAND_10);
K2_CONSTANT_BAND_10= str2double(val.LANDSAT_METADATA_FILE.LEVEL1_THERMAL_CONSTANTS.K2_CONSTANT_BAND_10);
TempSuperf = (K2_CONSTANT_BAND_10./log((EmissividadeNB.*K1_CONSTANT_BAND_10./L_TOA10)+1))-273.15;
TempSuperf(find(TempSuperf < -20))= NaN;
h = imagesc(TempSuperf);
axis off;
%figure;imshow(TempSuperf,[]);
%h = colormap(jet)
set(h, 'AlphaData', ~isnan(TempSuperf)); 
set(gca,'color','white');
colorbar
% Set the colormap to hsv: 
colormap
%saveas(gcf,'TempSuperf','png');
%close all