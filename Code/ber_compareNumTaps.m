close all; clear all;

numIter = 30; 

doppler = 0;
delay = 0;
EbN0 = 0:0.5:10;

numTaps = 5;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERlinNT(delay, doppler, EbN0(k), numTaps);
        end;
    end;
    berArr = mean(bers, 2);
    figure;
    semilogy(EbN0, berArr);
    xlabel('Eb/No (dB)')
    ylabel('BER')
    grid on;
    hold on;
    
numTaps = 20;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERlinNT(delay, doppler, EbN0(k), numTaps);
        end;
    end;
    berArr = mean(bers, 2);
    semilogy(EbN0, berArr);
    
 numTaps = 5;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERdfeNT(delay, doppler, EbN0(k), numTaps);
        end;
    end;
    berArr = mean(bers, 2);
    semilogy(EbN0, berArr); 
    
 numTaps = 20;   
    berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = computeBERdfeNT(delay, doppler, EbN0(k), numTaps);
        end;
    end;
    berArr = mean(bers, 2);
    semilogy(EbN0, berArr);

M = 4;
berTheory = berawgn(EbN0,'psk', M,'nondiff'); 

semilogy(EbN0, berTheory,'-r.');
legend('Lin 5',...
    'Lin 20',...
    'DFE 5',...
    'DFE 20',...
    'Theoretical QPSK','Location','SouthWest');
lgd = legend;
lgd.FontSize = 12;
lgd.Title.String = 'Num Taps';
hold off;
