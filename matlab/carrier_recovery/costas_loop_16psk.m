close all; clear all;

% qamcompare.m: compare real and complex QAM implementations
N=1000; M=20; Ts=.0001;       % # symbols, oversampling factor
time=Ts*(N*M-1); t=0:Ts:time; % sampling interval and time
%s1=pam(N,2,1); s2=pam(N,2,1); % length N real 2-level signals
symbs = exp(j*(0:2*pi/16:2*pi)); s16=symbs(randi(16,1,N));
ps=hamming(M);                % pulse shape of width M
fc=000; th1=rand(1)*2*pi; j=sqrt(-1); % carrier freq. and phase
s1up=zeros(1,N*M); s2up=zeros(1,N*M);
s1up(1:M:end)=real(s16);             % oversample by M
s2up(1:M:end)=imag(s16);             % oversample by M
sp1=filter(ps,1,s1up);        % convolve pulse shape with s1
sp2=filter(ps,1,s2up);        % convolve pulse shape with s2
% make real and complex-valued versions and compare
vreal=sp1.*cos(2*pi*fc*t+th1) -sp2.*sin(2*pi*fc*t+th1);
vcomp = real((sp1+j*sp2).*exp(j*(2*pi*fc*t+th1)));
max(abs(vcomp-vreal))         % verify that they're the same

% qamcostasloop.m simulate costas loop for QAM
% input vreal from qamcompare.m

r=vreal;                            % vreal from qamcompare.m
%r = (sp1+j*sp2) .* exp(j*(2*pi*fc*t+th));
fl=100; f=[0 .2 .3 1]; a=[1 1 0 0]; % filter specification
h=firpm(fl,f,a);                    % LPF design
mu=.003;                            % algorithm stepsize
f0=000; q=fl+1;                    % freq at receiver
th=zeros(1,length(t)); th(1)=(rand(1)*2*pi)-pi; % initialize estimate
z1=zeros(1,q); z2=zeros(1,q);       % initialize LPFs
z4=zeros(1,q); z3=zeros(1,q);       % z's contain past inputs
z5=zeros(1,q); z6=zeros(1,q);       % initialize LPFs
z8=zeros(1,q); z7=zeros(1,q);       % z's contain past inputs
z9=zeros(1,q); z10=zeros(1,q);       % initialize LPFs
z12=zeros(1,q); z11=zeros(1,q);       % z's contain past inputs
z13=zeros(1,q); z14=zeros(1,q);       % z's contain past inputs
z15=zeros(1,q); z16=zeros(1,q);       % z's contain past inputs
for k=1:length(t)-1
  s=2*r(k);
  z1=[z1(2:q),s*cos(2*pi*f0*t(k)+0*pi/16+th(k))];
  z2=[z2(2:q),s*cos(2*pi*f0*t(k)+1*pi/16+th(k))];
  z3=[z3(2:q),s*cos(2*pi*f0*t(k)+2*pi/16+th(k))];
  z4=[z4(2:q),s*cos(2*pi*f0*t(k)+3*pi/16+th(k))];
  z5=[z5(2:q),s*cos(2*pi*f0*t(k)+4*pi/16+th(k))];
  z6=[z6(2:q),s*cos(2*pi*f0*t(k)+5*pi/16+th(k))];
  z7=[z7(2:q),s*cos(2*pi*f0*t(k)+6*pi/16+th(k))];
  z8=[z8(2:q),s*cos(2*pi*f0*t(k)+7*pi/16+th(k))];
  z9=[z9(2:q),s*cos(2*pi*f0*t(k)+8*pi/16+th(k))];
  z10=[z10(2:q),s*cos(2*pi*f0*t(k)+9*pi/16+th(k))];
  z11=[z11(2:q),s*cos(2*pi*f0*t(k)+10*pi/16+th(k))];
  z12=[z12(2:q),s*cos(2*pi*f0*t(k)+11*pi/16+th(k))];
  z13=[z13(2:q),s*cos(2*pi*f0*t(k)+12*pi/16+th(k))];
  z14=[z14(2:q),s*cos(2*pi*f0*t(k)+13*pi/16+th(k))];
  z15=[z15(2:q),s*cos(2*pi*f0*t(k)+14*pi/16+th(k))];
  z16=[z16(2:q),s*cos(2*pi*f0*t(k)+15*pi/16+th(k))];
  
  
  lpf1=fliplr(h)*z1';               % output of filter 1
  lpf2=fliplr(h)*z2';               % output of filter 2
  lpf3=fliplr(h)*z3';               % output of filter 3
  lpf4=fliplr(h)*z4';               % output of filter 4
  lpf5=fliplr(h)*z5';
  lpf6=fliplr(h)*z6';
  lpf7=fliplr(h)*z7';
  lpf8=fliplr(h)*z8';
  lpf9=fliplr(h)*z9';
  lpf10=fliplr(h)*z10';
  lpf11=fliplr(h)*z11';
  lpf12=fliplr(h)*z12';
  lpf13=fliplr(h)*z13';
  lpf14=fliplr(h)*z14';
  lpf15=fliplr(h)*z15';
  lpf16=fliplr(h)*z16';
  th(k+1)=th(k)+mu*lpf1*lpf2*lpf3*lpf4*lpf5*lpf6*lpf7*lpf8*lpf9*lpf10*lpf11*lpf12*lpf13*lpf14*lpf15*lpf16; % algorithm update
end

plot(t,th),
title('Phase Tracking via the Costas Loop')
xlabel('time'); ylabel('phase offset')
