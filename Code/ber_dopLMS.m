close all; clear all;

numIter = 2; 

% fid = fopen("./parameters.txt");
% a = fscanf(fid, "%g\n", 2);
% EbN0 = a(1);
% delay = a(2);
% 
% line = [];
% while true 
%     line_t = fscanf(fid, "%g", 1);
%     line = [line line_t];
%     if size(line_t) == [0 0]
%         break
%     end
% end;
% 
% dopplerArr = line;

dopplerArr = 0:1:25;
delay = 0;
EbN0 = 30;

stepSize = 0.01;   
    berArr = [];
    for k = 1 : length(dopplerArr)
        for i = 1 : numIter
           bers(k,i) = compBERdopLMS(delay, dopplerArr(k), EbN0, stepSize);
        end;
    end;
    berArr = mean(bers, 2);
    figure;
    plot(dopplerArr, berArr,'-b','LineWidth',1);
    hold on;
    
stepSize = 0.03;   
    berArr = [];
    for k = 1 : length(dopplerArr)
        for i = 1 : numIter
           bers(k,i) = compBERdopLMS(delay, dopplerArr(k), EbN0, stepSize);
        end;
    end;
    berArr = mean(bers, 2);
    plot(dopplerArr, berArr,'-r','LineWidth',1);    
    
stepSize = 0.05;   
    berArr = [];
    for k = 1 : length(dopplerArr)
        for i = 1 : numIter
           bers(k,i) = compBERdopLMS(delay, dopplerArr(k), EbN0, stepSize);
        end;
    end;
    berArr = mean(bers, 2);
    plot(dopplerArr, berArr, '-g','LineWidth',1);
    
stepSize = 0.1;   
    berArr = [];
    for k = 1 : length(dopplerArr)
        for i = 1 : numIter
           bers(k,i) = compBERdopLMS(delay, dopplerArr(k), EbN0, stepSize);
        end;
    end;
    berArr = mean(bers, 2);
    plot(dopplerArr, berArr, '-m','LineWidth',1);
    

xlabel('Doppler (Hz)')
ylabel('BER')
grid on;
legend('0.01',...
    '0.03',...
    '0.05',...
    '0.1','Location','SouthEast');
lgd = legend;
lgd.FontSize = 12;
lgd.Title.String = ' StepSize';
hold off;
    
    
    

