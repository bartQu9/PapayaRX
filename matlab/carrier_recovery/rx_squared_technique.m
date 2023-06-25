%
% Copyright 2023, SatLab AGH
% Bartosz Rudnicki
%
close all; clear all;

fs = 40e6;
T = 1/10;
fc = 400e3;
fsym = 100e3; % symbol rate / frequency of symbols
sps = fs/fsym; % samples per symbol
f_shift = 11; ph_shift = pi/8;
dt = 1/fs;
df = fs/(fs*T); f = -fs/2:df:fs/2-df;
t = 0:dt:T-dt;
npow = 2; % raise rx to n power
nfc = 2; % passband n multiply of fc, 2 for rx^2, 4 for rx^4 etc..
constelation = 'BPSK'; % BPSK QPSK 8PSK 16PSK 16APSK 32APSK

b_find_fft_nfc_peak = 0; % 1

if strcmp(constelation, 'BPSK')
    % BPSK
    symbs = (sign(rand(1,fsym*T)*2-1));
elseif strcmp(constelation, 'QPSK')
    % QPSK
    constel = (exp(j*(pi/4:(2*pi)/4:2*pi))); symbs = constel(randi(4,1,fsym*T));
elseif strcmp(constelation, '8PSK')
    % 8PSK
    constel = (exp(j*(0:(2*pi)/8:2*pi))); symbs = constel(randi(8,1,fsym*T));
elseif strcmp(constelation, '16PSK')
    % 16PSK
    constel = (exp(j*(pi/8:(2*pi)/16:2*pi))); symbs = constel(randi(16,1,fsym*T));
elseif strcmp(constelation, '16APSK')
    % 16APSK
    gamma = 3.15; % 3.15 2.85 2.75 2.70 2.60 2.57 % available gammas for 16APSK
    R2=1; R1 = R2/gamma; constel = (R2*exp(j*(pi/12:(2*pi)/12:2*pi))); 
    constel = [constel (R1*exp(j*(pi/4:(2*pi)/4:2*pi)))]; 
    symbs = constel(randi(16,1,fsym*T));
elseif strcmp(constelation, '32APSK')
    % 32APSK
    % gammas pairs as commented below in columns
    gamma1 = 2.84; % 2.84 2.72 2.64 2.54 2.53 available gamma1 for 32APSK
    gamma2 = 5.27; % 5.27 4.87 4.64 4.33 4.30 available gamma2 for 32APSK
    R3 = 1; R1 = R3 / gamma2; R2 = R1 * gamma1;
    constel = (R3*exp(j*(0:(2*pi)/16:2*pi))); 
    constel = [constel (R2*exp(j*(pi/12:(2*pi)/12:2*pi)))];
    constel = [constel (R1*exp(j*(pi/4:(2*pi)/4:2*pi)))];
    symbs = constel(randi(32,1,fsym*T));
end

pt = zeros(1,T*fs); pt(1:sps:end) = symbs; % symbols pulse train
h_rc = rcosdesign(0.35, 6, sps, 'normal');
%h_rc = ones(1,sps);
bb = conv(pt,h_rc); bb = bb(1:length(pt)); % BaseBand signal - shaping by RC - FIR filtering
figure(1); subplot(2,2,1); stem(real(bb(end/2:(end/2)+(sps*100)))); subplot(2,2,2); stem(imag(bb(end/2:(end/2)+(sps*100)))); subplot(2,2,3); plot(bb(end/2:(end/2)+(sps*100))); subplot(2,2,4); plot(f,10*log10(abs(fftshift(fft(bb)))));

%with carrier
tx = real(bb .* exp(j*(2*pi*(fc+f_shift)*t + ph_shift)));
figure(2); subplot(2,1,1); stem(tx(end/2:(end/2)+(sps*100))); subplot(2,1,2); plot(f,10*log10(abs(fftshift(fft(tx)))));

% squared
rx = tx; rx = rx.^npow;
figure(3); subplot(2,1,1); stem(rx(end/2:(end/2)+sps*100)); subplot(2,1,2); plot(f,10*log10(abs(fftshift(fft(rx)))));

% pass only 2fc
bw_bp = 200; % BP bandwidth
h_bp = fir1(100000,[(nfc*fc-bw_bp/2)/(fs/2), (nfc*fc+bw_bp/2)/(fs/2)], 'bandpass');
figure(4); freqz(h_bp,1,f(1:100:end),fs);
rrx = conv(rx, h_bp); rrx=rrx(1:length(t));
rrx_fft = fftshift(fft(rrx));
figure(5); subplot(2,1,1); plot(rrx((end/2):(end/2)+sps*100)); subplot(2,1,2); plot(f,10*log10(abs(rrx_fft)));

% use fft to find doubled carrier
if b_find_fft_nfc_peak
    freq_peak = find(rrx_fft==max(rrx_fft(end/2:end)));
    f_freq_peak = f(freq_peak);
    [H,F]=freqz(h_bp,1,nfc*fc-3*fsym:df*1:nfc*fc+3*fsym,fs); % frequency response of BP filter around 2fc
    H_freq_peak = H(find(F==f_freq_peak)); % frequency response at freq peak
    angl_H_freq_peak = angle(H_freq_peak);
    angl_freq_peak = angle(rrx_fft(freq_peak));
    res_angl = mod(angl_freq_peak - angl_H_freq_peak, pi)/nfc; % recovered phase shift
    res_f = f_freq_peak/nfc; % recovered freq shift
    res_f
end


% PLL
c = pll(rrx, 1, nfc*fc, 40, fs);


