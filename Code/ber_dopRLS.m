close all; clear all;

numIter = 3; 

dopplerArr = 0:1:20;
delay = 0;
EbN0 = 30;

forgFactor = 0.99;   
     berArr = [];
    for k = 1 : length(dopplerArr)
        for i = 1 : numIter
           bers(k,i) = compBERdopRLS(delay, dopplerArr(k), EbN0, forgFactor);
        end;
    end;
    berArr = mean(bers, 2);
figure;
plot(dopplerArr, berArr, '-r','LineWidth',1);
hold on;
    
forgFactor = 0.95;   
     berArr = [];
    for k = 1 : length(dopplerArr)
        for i = 1 : numIter
           bers(k,i) = compBERdopRLS(delay, dopplerArr(k), EbN0, forgFactor);
        end;
    end;
    berArr = mean(bers, 2);
plot(dopplerArr, berArr, '-g','LineWidth',1);

forgFactor = 0.9;   
     berArr = [];
    for k = 1 : length(dopplerArr)
        for i = 1 : numIter
           bers(k,i) = compBERdopRLS(delay, dopplerArr(k), EbN0, forgFactor);
        end;
    end;
    berArr = mean(bers, 2);
plot(dopplerArr, berArr, '-b','LineWidth',1);

xlabel('Doppler Shift (Hz)')
ylabel('BER')
grid on;
legend('0.99',...
    '0.95',...
    '0.9','Location','SouthEast');
lgd = legend;
lgd.FontSize = 12;
lgd.Title.String = 'ForgettingFactor';
hold off;
    
    
    

