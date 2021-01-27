function BER = compBERraylchan(delay, dopplerShift, EbN0)

AveragePathGains = 1;

Fs = 2400; 
M = 4;
SPS_eq = 2;

SyncSequence = zeros (1, 64);
for i =  1 : 2 : 63
    SyncSequence(i) = 2;
end
PreambleSequence = mseq (2,5,0,1)+ 1;
numTrainSymbols = 200;
trainingSequence = randi([0 M-1], numTrainSymbols, 1);

DataLength = 256; 
information = randi([0 M-1],DataLength,1);

data = [SyncSequence, PreambleSequence', trainingSequence']';

% modulation
%signal = pskmod (data, M, pi/4);
signal = [ pskmod(data, M, pi/4) ; pskmod(information, M, pi/4,'gray') ];
%scatterplot(signal);
% title('QPSK-modulation');

preambleBaseband = pskmod (PreambleSequence, M, pi/4);
preambleBaseband = upsample (preambleBaseband, SPS_eq);

% rrc
RrcRollOff = 0.35;
RrcSps = 2 * SPS_eq;
RrcSpan = 20;
rrc = rcosdesign (RrcRollOff, RrcSpan, RrcSps);   
%fvtool(rrcT);
signal =  upfirdn (signal, rrc, RrcSps);   
Fs = Fs*4; 

%scatterplot(signal);
% title('RRC');

% CHANNEL
%SNR = (EbN0*2)/4;  *2 - потому что 2 бита, /4 - потому что полоса полезного сигнала в 4 раза меньше частоты дискретизации 
signal = awgn( signal , EbN0 - 10*log10(RrcSps) + 3,'measured');       

vfd = dsp.VariableFractionalDelay( ...
    'InterpolationMethod','Farrow','MaximumDelay',1025);
%delay = ;
vfdOut = vfd(signal, delay);
signal = vfdOut;

% scatterplot(signal);
% title('After delay');

% phase shift
% ph = 3* pi / 4;
% %ph = 0;
% signal = signal * exp(1i*ph);

%DopplerShift = 10;
% for i = 1: length(signal)
%     signal(i) = signal(i) * exp(2*pi*dopplerShift*i/Fs*1i);
% end;
%scatterplot(signal);
%title('WN, phase shift, Doppler');

rayleighchan = comm.RayleighChannel(...
    'SampleRate',Fs , ...
    'PathDelays', 0, ...
    'AveragePathGains', AveragePathGains, ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift', dopplerShift , ...
    'DopplerSpectrum', doppler('Gaussian', (0.5/2)/3));
rayleighchan2 = comm.RayleighChannel(...
    'SampleRate',Fs , ...
    'PathDelays', delay, ...
    'AveragePathGains', AveragePathGains, ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift', dopplerShift , ...
    'DopplerSpectrum', doppler('Gaussian', (0.5/2)/3));
signal = rayleighchan(signal) + rayleighchan2(signal);
% figure
% plot(abs(signal));
% RRC
signal =  upfirdn (signal, rrc, 1, 2);   
Fs = Fs/2; 
%fvtool(rrcR);
agc = comm.AGC('MaxPowerGain', 20, 'AveragingLength', 10, 'AdaptationStepSize', 5e-2);
signal = signal / rms(signal);
% figure();
signal = signal(150:end);
% plot(abs(signal));
% title('before');
[signal, power] = agc(signal);
% figure;
% plot(power);
% figure
% plot(abs(signal));
% title('after');

% preamble
Threshold = 20;
t=(1:length(signal))/Fs;
% sps_sync =
% symSynchro = comm.SymbolSynchronizer('SamplesPerSymbol', SPS_sync);
% [syncsignal,tError] = symSynchro(signal);
% Fs = Fs/2; 
% figure;
% % plot(t,tError);
% scatterplot (syncsignal);
% title('Symbol synchronizer');

prbdet = comm.PreambleDetector(preambleBaseband, 'Threshold', Threshold);
[idx, detmet] = prbdet(signal);
% figure;
% plot(detmet);
% title('Preamble detector');
% scatterplot (signal(1:end-20));
% title('Preamble');

if  ( isempty(idx) || ((length(signal) - idx(1)) < length(information) * SPS_eq)) 
    BER = 0.5;
    'detectError';
else
    ind = mod (1 : length(idx-1), 8) > 0;
    signaldetect = zeros(1, length(signal));
    signal = signal(idx+1:end);
    signal = [signal', zeros(1 , 4*SPS_eq + - mod(length(signal),SPS_eq))]';


% equalizer
refTap = 3*SPS_eq;
numPkts = 10;
%linEq =  comm.LinearEqualizer('Algorithm', 'LMS', ...
 %   'NumTaps',5*SPS_eq,'ReferenceTap',refTap,'StepSize',0.005,'InputSamplesPerSymbol',SPS_eq);
linEq =  comm.LinearEqualizer('Algorithm', 'RLS', ...
    'NumTaps',20*SPS_eq,'ReferenceTap',refTap,'ForgettingFactor',0.99,'InputSamplesPerSymbol',SPS_eq);

%,'InitialWeights',[0 0 1 0 0]
jj = 1;
TrainingBaseband = pskmod (trainingSequence, M, pi/4);
% figure
% plot(abs(signal(1:length(TrainingBaseband)) - TrainingBaseband));
% title('Error before eq');
% figure
    [signalOut,err] = linEq (signal, TrainingBaseband);
    reset(linEq)
%     plot(abs(err))
%         xlabel('Symbols')
%         ylabel('Error Magnitude')
%         axis([0,length(signal),0,1])
%         grid on;
% figure;
% plot(abs(err));
% title('eq err');
refTap = 3;        
% scatterplot (SignalOut(numTrainSymbols + RefTap: numTrainSymbols + RefTap + length(information) - 1));
% title('After equalization');

dataBeforeEq = pskdemod(signal,M, pi/4);
dataRec = pskdemod(signalOut,M, pi/4,'gray');
InfoBeforeEq = dataBeforeEq(numTrainSymbols + 1  : numTrainSymbols + DataLength);
InfoAfterEq = dataRec(numTrainSymbols + 3: numTrainSymbols + 3 + length(information) - 1);

%BER
k = log2(M); % Bits per symbol
binInfoAfterEq = de2bi(InfoAfterEq,k);
binInformation = de2bi(information,k);        
nErrors = biterr(binInformation, binInfoAfterEq);
errors = xor(binInfoAfterEq,binInformation);
BER = nErrors/length(InfoAfterEq)/k;

end