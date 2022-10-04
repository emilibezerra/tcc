% LANDSAT 5 
clc;clear; close all;
fname = 'LT05_L1TP_002067_20100723_20200823_02_T1_MTL.json';
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

%% 2010
% B4 = double(imread('RECORTE_B4.tif'));
% B3 = double(imread('RECORTE_B3.TIF'));
% B6 = double(imread('RECORTE_B6.TIF'));
% 
% B4 = double(imread('LT05_L1TP_002067_20100723_20200823_02_T1_B4.tif'));
% B3 = double(imread('LT05_L1TP_002067_20100723_20200823_02_T1_B3.TIF'));
% B6 = double(imread('LT05_L1TP_002067_20100723_20200823_02_T1_B6.TIF'));

meuretangle = [5348,1591,6921-5348,3224-1591];
B4 = imresize(double(imcrop(imread('LT05_L1TP_002067_20100723_20200823_02_T1_B4.TIF'),meuretangle)), [1411 1388]);
B3 = imresize(double(imcrop(imread('LT05_L1TP_002067_20100723_20200823_02_T1_B3.TIF'),meuretangle)), [1411 1388]);
B6 = imresize(double(imcrop(imread('LT05_L1TP_002067_20100723_20200823_02_T1_B6.TIF'),meuretangle)), [1411 1388]);

%==========================================
 %B4(find(B4>100)) = 0;
 mask_b4 = B4;
 mask_b4(find(mask_b4>0)) = 1;
 mask_b4 = imerode(mask_b4, strel('square', 20));
 mask_b6 = B6;
 mask_b6(find(mask_b6>0)) = 1;
 mask_b6 = imopen(mask_b6, strel('disk', 15));
 B3 = mask_b4 .* B3;
 B4 = mask_b4 .* B4 ;
 B6 = mask_b6 .* B6 ;
%B3(find(B3==0)) = 255;
% B6(find(B6==0)) = -20;
%==========================================



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
L_toaB4(find(L_toaB4==a_BAND4)) = 0;
L_toaB3(find(L_toaB3==a_BAND3)) = 0;
L_toaB6(find(L_toaB6==a_BAND6)) = 0;

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
%NDVI(find(NDVI==0.313725))= NaN;
NDVI = mask_b4 .* NDVI;
h = imagesc(NDVI);
axis off;
set(h, 'AlphaData', ~isnan(NDVI)); 
set(gca,'color','white');
c=colorbar
c.FontSize=14;
% Set the colormap to hsv: 
colormap


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
TempSuperf = (K2./log(((EmissividadeNB*K1)./L_toaB6)+1))-273.15;
TempSuperf = (K2./log(((EmissividadeNB*K1)./L_toaB6)+1))-273.15;
TempSuperf(find(TempSuperf < -20))= NaN;
figure;
h = imagesc(TempSuperf);
axis off;
set(h, 'AlphaData', ~isnan(TempSuperf)); 
set(gca,'color','white');
c=colorbar
c.FontSize=14;
% Set the colormap to hsv: 
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
