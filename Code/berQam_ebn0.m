close all; clear all;

numIter = 20; 

delay = 0;
dopplerShift = 0;
SPS_eq = 2;
EbN0 = 1:1:20;
berArr = [];
M = 64;
for k = 1 : length(EbN0)
    for i = 1 : numIter
       bers(k,i) =  compBERqam(delay, dopplerShift, EbN0(k), SPS_eq,M);
    end;  
end;

berArr = mean(bers, 2);

% figure;
% plot(EbN0, log(berArr));
% xlabel('EbN0')
% ylabel('BER')


berTheory = berawgn(EbN0,'qam', M); 

figure;
semilogy(EbN0, berArr,'-b.')
        xlabel('EbNo (dB)')
        ylabel('BER')
        grid on;
hold on;
semilogy(EbN0, berTheory,'-r.');
legend('BER QAM', ...
    'Theoretical BER','Location','SouthWest');
hold off;

