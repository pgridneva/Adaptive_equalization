close all; clear all;

numIter = 100; 

delay = 0;
dopplerShift = 0:1:15;
EbN0 = 50;

berArr = [];

for k = 1 : length(dopplerShift)
    for i = 1 : numIter
       bers(k,i) =  compBERraylchan(delay, dopplerShift(k), EbN0);
    end;  
end;

berArr = mean(bers, 2)

figure;
plot(dopplerShift, berArr);
xlabel('Doppler Spread (Hz)')
ylabel('BER')
grid on




