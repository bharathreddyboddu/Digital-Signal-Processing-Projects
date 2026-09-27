clear;
clc;
close all;

f1 = 3000;
f2 = 7000;
f3 = 9000;

%% ===== Continuous-Time Signal Generation =====
t_c = 0:0.0000001:0.01;

x1_c = 3*sin(2*pi*f1*t_c);
x2_c = 5*sin(2*pi*f2*t_c);
x3_c = 5*sin(2*pi*f3*t_c);

figure;

subplot(3,1,1);
plot(t_c,x1_c);
xlabel("time(sec)");
ylabel("x1(t)");
title("Continuous time domain signal x1(t)");
grid on;

subplot(3,1,2);
plot(t_c,x2_c);
xlabel("time(sec)");
ylabel("x2(t)");
title("Continuous time domain signal x2(t)");
grid on;

subplot(3,1,3);
plot(t_c,x3_c);
xlabel("time(sec)");
ylabel("x3(t)");
title("Continuous time domain signal x3(t)");
grid on;

%% ===== Sampling =====
fs = 150000;
ts = 1/fs;

t = 0:ts:1/1000-1/fs;

x1 = 3*sin(2*pi*f1*t);
x2 = 5*sin(2*pi*f2*t);
x3 = 5*sin(2*pi*f3*t);

n = 0:length(t)-1;

figure;

subplot(3,1,1);
stem(n,x1);
xlabel("n");
ylabel("x1[n]");
title("Sampled signal x1[n]");
grid on;

subplot(3,1,2);
stem(n,x2);
xlabel("n");
ylabel("x2[n]");
title("Sampled signal x2[n]");
grid on;

subplot(3,1,3);
stem(n,x3);
xlabel("n");
ylabel("x3[n]");
title("Sampled signal x3[n]");
grid on;

%% ===== Signal Combination and FFT Analysis =====
x11 = 6*x1;
x4 = x11 + x2;

X4 = fft(x4,length(x4));

figure;

N1 = length(x4);
k1 = 0:N1-1;

subplot(2,1,1);
stem(k1,x4);
xlabel("n");
ylabel("x4[n]");
title("x4[n] = 6*x1[n] + x2[n]");
grid on;

subplot(2,1,2);
stem(fs*k1/N1,abs(X4));
xlabel("Frequencies(Hertz)");
ylabel("|X4(k)|");
title("Magnitude response of x4[k] (before filtering)");
grid on;

%% ===== FIR Low-Pass Filter Design =====
N = 100;

hamm = hamming(N+1);

fc = 5000;

b = fir1(N,2*fc/fs,"low",hamm);

figure;
freqz(b,1,1024);

[h,l] = impz(b,1);

figure;

stem(l,h);
xlabel("n");
ylabel("h[n]");
title("Impulse response of the filter h[n] (Hamming window)");
grid on;

%% ===== Filtering =====
x_f = conv(x4,h);

N2 = length(x_f);

X_f = fft(x_f,N2);

k2 = 0:N2-1;

figure;

subplot(2,1,1);
stem(k2,x_f);
xlabel("n");
ylabel("x_f[n]");
title("Filtered signal x_f");
grid on;

subplot(2,1,2);
stem(fs*k2/N2,abs(X_f));
xlabel("Frequencies (hertz)");
ylabel("|X_f(k)|");
title("Magnitude response after filtering of x4[n]");
grid on;

%% ===== Delay for x3 =====
x31 = [0,x3(1:end)];

N3 = length(x31);

if N2 > N3
    x31 = [x31,zeros(1,N2-N3)];
else
    x_f = [x_f,zeros(1,N3-N2)];
end

n1 = 0:length(x31)-1;

figure;

subplot(2,1,1);
stem(n,x3);
xlabel("n");
ylabel("x3[n]");
title("Sampled signal x3[n]");
grid on;

subplot(2,1,2);
stem(n1,x31);
xlabel("n");
ylabel("x31[n]");
title("Delayed signal and zero padded signal x31[n]");
grid on;

%% ===== Final Output and FFT =====
y = x_f + x31;

N4 = length(y);

k4 = 0:N4-1;

Y = fft(y,N4);

figure;

subplot(2,1,1);
stem(n1,y);
xlabel("n");
ylabel("y[n]");
title("y[n] = x31[n] + x_f[n]");
grid on;

subplot(2,1,2);
stem(fs*k4/N4,abs(Y));
xlabel("Frequencies(hertz)");
ylabel("|Y(k)|");
title("Magnitude spectrum of Y(k)");
grid on;

%% ===== Display Results =====
disp("==============================================");
disp("FREQUENCY-SELECTIVE SIGNAL PROCESSING");
disp("==============================================");

disp("Sampling Frequency:");
disp(fs);

disp("Frequencies of Input Signals:");
disp(f1);
disp(f2);
disp(f3);

disp("Filter Cutoff Frequency:");
disp(fc);

disp("Filter Order:");
disp(N);

disp("Final Output Signal y[n]:");
disp(y);