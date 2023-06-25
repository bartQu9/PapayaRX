close all; clear all;

fs = 20e6; Ts = 1/fs;
fsym = 100e3; % symb freq
N = 2000; % N symbols
sps = fs/fsym; % samples per symbol
fc = 600e3;
ph1 = pi/16;
T=N*sps*Ts; t=0:Ts:T-Ts;

phi_avail = (2*pi/8)*(0:7); phis=phi_avail(randi(8,1,N));
symbs = exp(j*phis);
bb = zeros(1,N*sps); bb(1:sps:end) = symbs;
h = rcosdesign(0.45, 6, sps, 'normal');
%h = ones(1,sps);
bb = conv(bb,h); bb = bb(length(h):end);

s = cos(2*pi*fc*t+bb+ph1);
s = bb .* exp(j*(2*pi*fc*t + ph1));
df = fs/length(s); f=-fs/2:df:fs/2-df; S=fftshift(fft(s)); 
figure(1); plot(f,10*log10(abs(S)));

sa = s;
SA=fftshift(fft(sa)); 
figure(2); plot(f,10*log10(abs(SA)));

mi=.001;
theta2 = [0];
ud=zeros(1,100000);
for k = 1:length(sa)
    
    um(k) = sa(k) .* exp(-j*(2*pi*fc*t(k) + theta2(k)));
    
    phi_out = angle2(um(k));
    phi_est = round((phi_out)/(2*pi/8))*(2*pi/8);
    ud(k) = phi_out - phi_est;
    theta2(k+1) = mean(ud(end-99999:end));
end

figure; plot(theta2)
figure; plot(um,'o')
hold on
plot(um.*exp(-j*(mean(theta2))),'x')
