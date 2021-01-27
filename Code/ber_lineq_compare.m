close all; clear all;

numIter = 10; 

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


    
FF = 0.95;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERlin2(delay, doppler, EbN0(k), FF);
        end;
    end;
    berArr = mean(bers, 2);
    semilogy(EbN0, berArr);
    
    FF = 0.99;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERlin2(delay, doppler, EbN0(k), FF);
        end;
    end;
    berArr = mean(bers, 2);
    semilogy(EbN0, berArr);
    
M = 4;
berTheory = berawgn(EbN0,'psk', M,'nondiff'); 

semilogy(EbN0, berTheory,'-r.');
legend('LMS: StepSize 0.01',...
    'LMS: StepSize 0.05',...
    'RLS: ForgettingFactor 0.95',...
    'RLS: ForgettingFactor 0.99',...
    'Theoretical QPSK','Location','SouthWest');
lgd = legend;
lgd.FontSize = 12;
lgd.Title.String = 'Linear Equalizer';
hold off;
    
    
    
