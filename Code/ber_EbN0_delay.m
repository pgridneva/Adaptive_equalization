close all; clear all;

numIter = 10; 
doppler = 0;
EbN0 = 1:0.5:10;
Ts = 1/2400;

fractDelay = 0;
SPS = 1;
delay = fractDelay;
 berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = compBERdel(delay, doppler, EbN0(k), SPS);
        end;
    end;
    berArr = mean(bers, 2);
figure;
semilogy(EbN0, berArr,'-b');
hold on;

fractDelay = 0.25;
SPS = 1;
delay = fractDelay*Ts;
 berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = compBERdel(delay, doppler, EbN0(k), SPS);
        end;
    end;
    berArr = mean(bers, 2);
semilogy(EbN0, berArr,'-g');

fractDelay = 0.5;
SPS = 1;
delay = fractDelay*Ts;
 berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = compBERdel(delay, doppler, EbN0(k), SPS);
        end;
    end;
    berArr = mean(bers, 2);
semilogy(EbN0, berArr,'-y');

fractDelay = 0.25;
SPS = 2;
delay = fractDelay*Ts;
 berArr = [];
    for k = 1 : length(EbN0)
        for i = 1 : numIter
           bers(k,i) = compBERdel(delay, doppler, EbN0(k), SPS);
        end;
    end;
    berArr = mean(bers, 2);
semilogy(EbN0, berArr,'-m');

M = 4;
berTheory = berawgn(EbN0,'psk', M,'nondiff'); 
semilogy(EbN0, berTheory,'-r.');
legend('1,0',...
    '1, 0.25 Ts',...
    '1, 0.5 Ts',...
    '2, 0.25 Ts',...
   'Theoretical BER',...,
    'Location','SouthWest');
xlabel('EbNo (dB)')
ylabel('BER')
grid on;
lgd = legend;
lgd.FontSize = 12;
lgd.Title.String = 'SPS, Delay';
hold off;