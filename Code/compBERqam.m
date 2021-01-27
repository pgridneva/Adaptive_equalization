function BER = compBERqam(delay, dopplerShift, EbN0, SPS_eq, Mqam)

Fs = 2400; 

%SPS_eq = 4;
%Mqam = 16;
Mpsk = 4;

Constellation = qammod (0:Mqam-1, Mqam,'UnitAveragePower',1);

SyncSequence = zeros (1, 64);
for i =  1 : 4 : 63
    SyncSequence(i) = 0;
    SyncSequence(i+1) = 1;
    SyncSequence(i+2) = 2;
    SyncSequence(i+3) = 3;
end

PreambleSequence = mseq (2,6,0,1)+ 1;
preambleLength = length(PreambleSequence);
numTrainSymbols = 400;
trainingSequence = randi([0 Mqam - 1], numTrainSymbols, 1);

DataLength = 512; 
information = randi([0 Mqam - 1], DataLength, 1);

data = [SyncSequence, PreambleSequence']';
info = [trainingSequence', information']';

data = pskmod(data, Mpsk, pi/4);

signal = [data; qammod(info, Mqam,'UnitAveragePower' , 1) ];

preambleBaseband = pskmod (PreambleSequence, Mpsk, pi/4);
preambleBaseband = upsample (preambleBaseband, SPS_eq);

RrcRollOff = 0.35;
RrcSps = 2 * SPS_eq;
RrcSpan = 20;
rrc = rcosdesign (RrcRollOff, RrcSpan, RrcSps);   
%fvtool(rrc);
signal =  upfirdn (signal, rrc, RrcSps);   
Fs = Fs * RrcSps; 

signal = awgn( signal , EbN0 - 10*log10(RrcSps) + 10*log10(log2(Mqam)), 'measured');       


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
% scatterplot(signal);
% title ('After channel');

% rayleighchan = comm.RayleighChannel(...
%     'SampleRate',Fs , ...
%     'PathDelays', 0, ...
%     'AveragePathGains', AveragePathGains, ...
%     'NormalizePathGains',true, ...
%     'MaximumDopplerShift', dopplerShift , ...
%     'DopplerSpectrum', doppler('Gaussian', (0.5/2)/3));
% rayleighchan2 = comm.RayleighChannel(...
%     'SampleRate',Fs , ...
%     'PathDelays', delay, ...
%     'AveragePathGains', AveragePathGains, ...
%     'NormalizePathGains',true, ...
%     'MaximumDopplerShift', dopplerShift , ...
%     'DopplerSpectrum', doppler('Gaussian', (0.5/2)/3));
% signal = rayleighchan(signal) + rayleighchan2(signal);
% figure
% plot(abs(signal));

signal =  upfirdn (signal, rrc, 1, 2);   
Fs = Fs/2;
%fvtool(rrcR);

agc = comm.AGC('MaxPowerGain', 20, 'AveragingLength', 200, ...
    'AdaptationStepSize', 5e-3);
signal = signal / rms(signal);
signal = signal(150:end);
% figure();
% plot(abs(signal));
% title('Before AGC');
[signal, power] = agc(signal);
%  figure;
%  plot(power);
%  title('power');
% figure
% plot(abs(signal));
% title('After AGC');

% preamble
Threshold = preambleLength/2;
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


if  ( isempty(idx) || ((length(signal) - idx(1)) < length(information) * SPS_eq)) 
    BER = 0.5;
    'detectError'
else
    ind = mod (1 : length(idx-1), 8) > 0;
    signaldetect = zeros(1, length(signal));
    signal = signal(idx+1:end);
    signal = [signal', zeros(1 , 4*SPS_eq + - mod(length(signal), SPS_eq))]';

refTap = 10;
numPkts = 10;
numTaps = 20;
% figure;
%signalplot = downsample(signal,SPS_eq,2);
%  scatterplot (signalplot(numTrainSymbols : end - 20));
%  title('total');
linEq =  comm.LinearEqualizer('Algorithm', 'LMS', ...
    'NumTaps',20*SPS_eq,'ReferenceTap',refTap * SPS_eq,'StepSize',0.01,'InputSamplesPerSymbol',SPS_eq, ...
    'Constellation', Constellation);
%linEq =  comm.LinearEqualizer('Algorithm', 'RLS', ...
%     'NumTaps',20*SPS_eq,'ReferenceTap',refTap*SPS_eq,'ForgettingFactor',0.995,'InputSamplesPerSymbol',SPS_eq,...
%     'Constellation', qammod(0:Mqam-1, Mqam) / sqrt(AveragePower));

%,'InitialWeights',[0 0 1 0 0]
jj = 1;
TrainingBaseband = qammod (trainingSequence, Mqam,'UnitAveragePower' , 1);
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
% scatterplot (SignalOut(numTrainSymbols + RefTap: numTrainSymbols + RefTap + length(information) - 1));
% title('After equalization');

dataBeforeEq = qamdemod(signal,Mqam);
dataRec = qamdemod(signalOut, Mqam,'UnitAveragePower',1);
InfoBeforeEq = dataBeforeEq(numTrainSymbols + 1  : numTrainSymbols + DataLength);
InfoAfterEq = dataRec(numTrainSymbols + refTap: numTrainSymbols + refTap + DataLength - 1);

k = log2(Mqam); % Bits per symbol
binInfoAfterEq = de2bi(InfoAfterEq,k);
binInformation = de2bi(information,k);        
nErrors = biterr(binInformation, binInfoAfterEq);
errors = xor(binInfoAfterEq,binInformation);
BER = nErrors/length(InfoAfterEq)/k;
end