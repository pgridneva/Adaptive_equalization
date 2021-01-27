close all; clear all;

numIter = 10; 

% fid = fopen("./parameters.txt");
% a = fscanf(fid, "%g\n", 2);
% doppler = a(1);
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
% EbN0 = line;

doppler = 0;
delay = 0;
EbN0 = 0:0.5:10;

berArr =  [];
for k = 1 : length(EbN0)
    for i = 1 : numIter
       bers(k,i) =  computeBER(delay, doppler, EbN0(k));
    end;  
end;

berArr = mean(bers, 2);

M = 4;
berTheory = berawgn(EbN0,'psk', M,'nondiff'); 

figure;
semilogy(EbN0, berArr,'-b.')
        xlabel('Eb/No (dB)')
        ylabel('BER')
        grid on;
hold on;
semilogy(EbN0, berTheory,'-r.');
legend('QPSK',...
    'Theoretical BER','Location','SouthWest');
hold off;




