close all; clear all;

% qamcompare.m: compare real and complex QAM implementations
N=1000; M=20; Ts=.0001;       % # symbols, oversampling factor
time=Ts*(N*M-1); t=0:Ts:time; % sampling interval and time
s1=pam(N,2,1); s2=pam(N,2,1); % length N real 2-level signals
ps=hamming(M);                % pulse shape of width M
fc=1000; th=-1.0; j=sqrt(-1); % carrier freq. and phase
s1up=zeros(1,N*M); s2up=zeros(1,N*M); 
s1up(1:M:end)=s1;             % oversample by M
s2up(1:M:end)=s2;             % oversample by M
sp1=filter(ps,1,s1up);        % convolve pulse shape with s1
sp2=filter(ps,1,s2up);        % convolve pulse shape with s2
% make real and complex-valued versions and compare
vreal=sp1.*cos(2*pi*fc*t+th)-sp2.*sin(2*pi*fc*t+th);
vcomp = real((sp1+j*sp2).*exp(j*(2*pi*fc*t+th)));
max(abs(vcomp-vreal))         % verify that they're the same

% qamcostasloop.m simulate costas loop for QAM
% input vreal from qamcompare.m

r=vreal;                            % vreal from qamcompare.m
fl=100; f=[0 .2 .3 1]; a=[1 1 0 0]; % filter specification
h=firpm(fl,f,a);                    % LPF design
mu=.003;                            % algorithm stepsize
f0=1000; q=fl+1;                    % freq at receiver
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
