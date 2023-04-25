clear;

if ~exist('dvbs2xLDPCParityMatrices.mat','file')
    if ~exist('s2xLDPCParityMatrices.zip','file')
        url = 'https://ssd.mathworks.com/supportfiles/spc/satcom/DVB/s2xLDPCParityMatrices.zip';
        websave('s2xLDPCParityMatrices.zip',url);
        unzip('s2xLDPCParityMatrices.zip');
    end
addpath('s2xLDPCParityMatrices');
end

numFrames = 1;

s2WaveGen = dvbs2WaveformGenerator;
s2WaveGen.MODCOD = 21;              % 16APSK 5/6
s2WaveGen.DFL = 39690;
s2WaveGen.HasPilots = true;         % Pilot insertion indication
disp(s2WaveGen)

syncBits = [0 1 0 0 0 1 1 1]';    % Sync byte for TS packet is 47 Hex
pktLen = 1496;                    % UP length without sync bits is 1496
numPkts = s2WaveGen.MinNumPackets*numFrames;
txRawPkts = randi([0 1],pktLen,numPkts);
txPkts = [repmat(syncBits,1,numPkts); txRawPkts];
data = txPkts(:);

txWaveform = s2WaveGen(data);

sps = s2WaveGen.SamplesPerSymbol;
constel = comm.ConstellationDiagram('ColorFading',true, ...
    'ShowTrajectory',0, ...
    'SamplesPerSymbol',sps, ...
    'ShowReferenceConstellation',false, ...
    'XLimits',[-0.5 0.5], 'YLimits',[-0.5 0.5]);
plHeaderLen = 90*sps;           % PL header length
constel(txWaveform(plHeaderLen+1:end));
release(constel);

BW = 36e6;                 % Typical satellite channel bandwidth
Fsym = BW/(1+s2WaveGen.RolloffFactor);
Fsamp = Fsym*sps;
scope = spectrumAnalyzer('SampleRate',Fsamp);
scope(txWaveform)



% s2WaveGen = dvbs2WaveformGenerator;
% data = zeros(0,1);
% txWaveform = s2WaveGen(data);
