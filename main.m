close all; clear;
i = imread("LC08_L1TP_216066_20141001_20170418_01_T1_B10.TIF");
B4 = imread("LC08_L1TP_216066_20141001_20170418_01_T1_B4.TIF");
B5 = imread("LC08_L1TP_216066_20141001_20170418_01_T1_B5.TIF");
figure; imshow(i, []);


RADIANCE_MULT_BAND_10 = 3.3420E-04;
RADIANCE_ADD_BAND_10 = 0.10000;

REFLECTANCE_MULT_BAND_4 = 2.0000E-05;
REFLECTANCE_MULT_BAND_5 = 2.0000E-05;
REFLECTANCE_ADD_BAND_4 = -0.100000;
REFLECTANCE_ADD_BAND_5 = -0.100000;

%Lλ=MLQcal+AL
L  = ( RADIANCE_MULT_BAND_10 .* double(i))+RADIANCE_ADD_BAND_10;
figure; imshow(L, []);

%ρλ′=MρQcal+Aρ
P4_  = (double(B4) .* REFLECTANCE_MULT_BAND_4)+REFLECTANCE_ADD_BAND_4;
figure; imshow(P4_, []);
P5_  = (double(B5) .* REFLECTANCE_MULT_BAND_5)+REFLECTANCE_ADD_BAND_5;
figure; imshow(P5_, []);

%TOA reflectance with a correction for the sun angle is then:
%ρλ=ρλ′/cos(θSZ)=ρλ′/sin(θSE)
%ρλ          = TOA planetary reflectance
%θSE         = Local sun elevation angle. The scene center sun elevation angle in degrees is provided in the metadata (SUN_ELEVATION). 
%θSZ         = Local solar zenith angle;  θSZ = 90° - θSE
P4 = P4_/cos(90);
figure; imshow(P4, []);

%NDVI = (Band 5 – Band 4) / (Band 5 + Band 4)
NDVI = (double(B5) - double(B4)) ./ (double(B5) + double(B4));
figure; imshow(NDVI, []);

PV= (NDVI-0.26)/(0.636-0.26);
E = 0.004 * PV + 0.986;
%Conversion to Top of Atmosphere Brightness Temperature
%BT = (K2 / (ln (K1 / L) + 1)) − 273.15
K1_CONSTANT_BAND_10 = 774.8853;
K2_CONSTANT_BAND_10 = 1321.0789;
BT = K2_CONSTANT_BAND_10 ./(log(K1_CONSTANT_BAND_10 ./ P4_)+1)-273.15;
figure; imshow(BT, []);
LST = (BT ./ (1 + (0.00115 .* BT ./ 1.4388) .* log(E)));
%T=K2ln(K1Lλ+1)