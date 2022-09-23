close all;
figure; title('Temperatura em °C');
 plot(TEMP_1995, 'DisplayName', '1995','LineWidth',2,'Color','#cc9900');
hold on
plot(TEMP_2000, 'DisplayName', '2000','LineWidth',2,'Color','#ff9900');
hold on
plot(TEMP_2005, 'DisplayName', '2005','LineWidth',2,'Color','#cc6600');
hold on
plot(TEMP_2010, 'DisplayName', '2010','LineWidth',2,'Color','#ff3300');
hold on
plot(TEMP_2015, 'DisplayName', '2015','LineWidth',2,'Color','#ff0000');
hold on
plot(TEMP_2021, 'DisplayName', '2021','LineWidth',2,'Color','#cc0000');
hold on
xlabel('Pixels amostrados')
 ylabel('Temperatura em °C')
lgd = legend('Location','bestoutside')
lgd.Title.String = 'Legenda'

figure; title('NDVI');
 plot(NDVI_1995, 'DisplayName', '1995','LineWidth',2,'Color','#ffccff');
hold on
plot(NDVI_2000, 'DisplayName', '2000','LineWidth',2,'Color','#ff99ff');
hold on
plot(NDVI_2005, 'DisplayName', '2005','LineWidth',2,'Color','#ff66ff');
hold on
plot(NDVI_2010, 'DisplayName', '2010','LineWidth',2,'Color','#ff00ff');
hold on
plot(NDVI_2015, 'DisplayName', '2015','LineWidth',2,'Color','#cc00cc');
hold on
plot(NDVI_2021, 'DisplayName', '2021','LineWidth',2,'Color','#660066');
hold on
xlabel('Pixels amostrados')
 ylabel('NDVI')
lgd = legend('Location','bestoutside')
lgd.Title.String = 'Legenda'