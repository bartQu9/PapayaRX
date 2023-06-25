% lab19_ex_PLL.m - digital Phase-Locked Loop
%TZ

function [c] = pll(s, ipll, fPLLstart, dfreq, fs)
% ipll 1=real PLL, 2=complex PLL
% fPLLstart = fc-25;  % initial PLL freq.
% dfreq = 40; % freq. lock (synchro bandwidth)

N = length(s);

% Calculation of adaptation constants
damp = sqrt(2)/2;                                       % standard damping
omeg = (dfreq/fs) / (damp+1/(4*damp));                  % constant  
mi1   = (4*damp*omeg) / (1 + 2*damp*omeg + omeg*omeg);  % adapt speed const #1
mi2   = (4*omeg*omeg) / (1 + 2*damp*omeg + omeg*omeg);  % adapt speed const #2

% PLL
omega = zeros(1,N+1); omega(1) = 2*pi*fPLLstart / fs;
theta = zeros(1,N+1);
smax = max(abs(s));
for n = 1 : N                                           % PLL adaptation loop
    if( ipll==1 ) delta = -2*sin(theta(n)) * s(n)/smax;
    else          delta = -2*imag( exp(j*theta(n)) * conj(s(n) )/smax );
    end    
    theta(n+1) = theta(n) + omega(n) + mi1*delta;
    omega(n+1) = omega(n) + mi2*delta;
end
c = cos(  theta(1:N) );    % recovered carrier
sr = real(s) / smax;       % real part of input distorted carrier 
n = 1:10000;
plot(n,sr(n),'r.-',n,c(n),'b.-'); title('s(n) and c(n)'); grid; pause
figure; plot(1:N,sr-c,'r-'); title('s(n)-c(n)'); grid; pause
figure; plot(theta); title('\theta(n) [rad]');grid; pause
figure; plot(omega*fs/(2*pi),'b-'); xlabel('n'); title('f_{PLL}(n) [Hz]'); grid; pause
