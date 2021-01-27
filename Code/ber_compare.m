close all; clear all;

numIter = 20; 

doppler = 0;
delay = 0;
EbN0 = 0:0.5:10;

stepSize = 0.01;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERlin(delay, doppler, EbN0(k), stepSize);
        end;
    end;
    berArr = mean(bers, 2);
    figure;
    semilogy(EbN0, berArr);
    xlabel('Eb/No (dB)')
    ylabel('BER')
    grid on;
    hold on;
    
stepSize = 0.05;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERlin(delay, doppler, EbN0(k), stepSize);
        end;
    end;
    berArr = mean(bers, 2);
    semilogy(EbN0, berArr);
    
 stepSize = 0.001;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERdfe(delay, doppler, EbN0(k), stepSize);
        end;
    end;
    berArr = mean(bers, 2);
    semilogy(EbN0, berArr); 
    
 stepSize = 0.01;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERdfe(delay, doppler, EbN0(k), stepSize);
        end;
    end;
    berArr = mean(bers, 2);
    semilogy(EbN0, berArr);
%     
% stepSize = 0.1;   
%     berArr = [];
%     for k = 1 : length(EbN0)
%         for i = 1 : numIter
%            bers(k,i) = computeBERdfe(delay, doppler, EbN0(k), stepSize);
%         end;
%     end;
%     berArr = mean(bers, 2);
%     semilogy(EbN0, berArr);   
    


M = 4;
berTheory = berawgn(EbN0,'psk', M,'nondiff'); 

semilogy(EbN0, berTheory,'-r.');
legend('Lin 0.01',...
    'Lin 0.05',...
    'DFE 0.001',...
    'DFE 0.01',...
    'Theoretical QPSK','Location','SouthWest');
lgd = legend;
lgd.FontSize = 12;
lgd.Title.String = 'StepSize';
hold off;




