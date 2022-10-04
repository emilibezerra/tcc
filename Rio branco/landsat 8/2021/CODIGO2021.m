% LANDSAT 8 
clc;clear; close all;
fname = 'LC08_L1TP_002067_20210923_20211003_02_T1_MTL.json';
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

%% 2021
meuretangle = [5247,2303,6481-5247,3598-2303];
BIV = imresize(double(imcrop(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B5.TIF'),meuretangle)),[1411 1388]);
BV = imresize(double(imcrop(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B4.TIF'),meuretangle)),[1411 1388]);
B_INF = imresize(double(imcrop(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B10.TIF'),meuretangle)),[1411 1388]);

% BIV = double(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B5.tif'));
% BV = double(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B4.TIF'));
% B_INF = double(imread('LC08_L1TP_002067_20210923_20211003_02_T1_B10.TIF'));


% BV = double(imread('TESTE_B4.TIF'));
% BIV = double(imread('TESTE_B5.TIF'));
% B_INF = double(imread('TESTE_B10.TIF'));

% 
% BV(find(BV>12000))= mean(BV(:));
% BIV(find(BIV>20000))= mean(BIV(:));
% B_INF(find(B_INF<25000))= mean(B_INF(:));

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
h = imagesc(NDVI, [0 1]);
 axis off;
 set(h, 'AlphaData', ~isnan(NDVI)); 
 set(gca,'color','white');
 c=colorbar
 c.FontSize=14;
 %Set the colormap to hsv: 
colormap


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
figure;
h = imagesc(TempSuperf);
axis off;
set(h, 'AlphaData', ~isnan(TempSuperf)); 
set(gca,'color','white');
c=colorbar
c.FontSize=14;
colormap


%Perfil selicionado no mapa
% x1 = 6052; y1 = 1763;
% x2 = 5889; y2 = 1763;
%%
x1 = 1; y1 = 1411;
x2 = 1388; y2 = 1;

% a_temp = TempSuperf(y1:y2 , x2:x1 );
a_temp = rot90(TempSuperf', -1);
d_a_temp = diag(a_temp);
% d_a_temp = d_a_temp/max(d_a_temp);
b_temp = insertShape(NDVI, 'Line', [x1 y1 x2 y2 ], 'Color', 'red', 'LineWidth',3);
figure; imshow(b_temp, []); title('Região Amostrada');
%%
% teste = NDVI;
% teste(find(teste<0))=-1;
% teste(teste>=0 & teste<0.2)=1;
% teste(teste>=0.2 & teste<0.4)=2;
% teste(teste>=0.4 & teste<0.6)=3;
% teste(teste>=0.6 & teste<0.8)=4;
% NDVI=teste;
% a_ndvi =NDVI(y1:y2 , x2:x1);
a_ndvi = rot90(NDVI', -1);
a_ndvi = a_ndvi;
d_a_ndvi = diag(a_ndvi);

 figure; title('Perfil 2010');
 yyaxis left
 plot(d_a_temp, 'DisplayName', 'Temperatura C°','LineWidth',2);
 ylabel('Temperatura em C°')

hold on
yyaxis right
plot(d_a_ndvi, 'DisplayName', 'NDVI','LineWidth',2)
ylabel('NDVI')
xlabel('Pixels amostrados')
lgd = legend('Location','bestoutside')
lgd.Title.String = 'Legenda'

%Correlação entre o ndvi e a Temperatura de superficie
[rho, pval] = corr(d_a_temp', d_a_ndvi', 'Type', 'Spearman');
[rho, pval] = corr(d_a_temp', d_a_ndvi', 'Type', 'Pearson');
