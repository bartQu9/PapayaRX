close all; clear all;

fs = 2e6; Ts = 1/fs;
fsym = 100e3; % symb freq
N = 2000; % N symbols
sps = fs/fsym; % samples per symbol
fc = 600e3;
ph1 = pi/4;
T=N*sps*Ts; t=0:Ts:T-Ts;

constel = exp(j*(pi/4:2*pi/4:2*pi)); symbs=constel(randi(4,1,N));
bb = zeros(1,N*sps); bb(1:sps:end) = symbs;
h = rcosdesign(0.45, 6, sps, 'normal');
bb = conv(bb,h); bb = bb(length(h):end);
rf = real(bb .* exp(j*(2*pi*fc*t+ph1)));

r=rf;                            % vreal from qamcompare.m
fl=100; f=[0 .2 .3 1]; a=[1 1 0 0]; % filter specification
h=firpm(fl,f,a);                    % LPF design
mu=.003;                            % algorithm stepsize
f0=fc; q=fl+1;                    % freq at receiver
th=zeros(1,length(t)); th(1)=randn; % initialize estimate
z1=zeros(1,q); z2=zeros(1,q);       % initialize LPFs
z4=zeros(1,q); z3=zeros(1,q);       % z's contain past inputs
for k=1:length(t)-1
  s=2*r(k);
  z1=[z1(2:q),s*cos(2*pi*f0*t(k)+th(k))];
  z2=[z2(2:q),s*cos(2*pi*f0*t(k)+pi/4+th(k))];
  z3=[z3(2:q),s*cos(2*pi*f0*t(k)+pi/2+th(k))];
  z4=[z4(2:q),s*cos(2*pi*f0*t(k)+3*pi/4+th(k))];
  lpf1=fliplr(h)*z1';               % output of filter 1
  lpf2=fliplr(h)*z2';               % output of filter 2
  lpf3=fliplr(h)*z3';               % output of filter 3
  lpf4=fliplr(h)*z4';               % output of filter 4
  th(k+1)=th(k)+mu*lpf1*lpf2*lpf3*lpf4; % algorithm update
end

plot(t,th),
title('Phase Tracking via the Costas Loop')
xlabel('time'); ylabel('phase offset')