%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: D:\AGH\SEMESTR_6\Elektroniczna aparatura medyczna\Ćwiczenia projektowe\sygnały eam\sygnały eam
%
% Auto-generated by MATLAB on 06-May-2022 16:12:00

%% Setup the Import Options and import the data
clear all;
close all;

opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [32, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["MegaWinASCIIfile", "VarName2"];
opts.VariableTypes = ["double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "MegaWinASCIIfile", "TrimNonNumeric", true);
opts = setvaropts(opts, "MegaWinASCIIfile", "ThousandsSeparator", ",");

% Import the data
tasma_fioletowa = readtable("C:\Users\Asus\Desktop\semestr 6\EAM\projekt\eam\Ania\guma_fioletowa.ASC", opts);
tasma_czerwona = readtable("C:\Users\Asus\Desktop\semestr 6\EAM\projekt\eam\Ania\guma_czerwona.ASC", opts);
tasma_czarna = readtable("C:\Users\Asus\Desktop\semestr 6\EAM\projekt\eam\Ania\guma_czarna.ASC", opts);
%% Convert to output type
tasma_fioletowa = table2array(tasma_fioletowa);
tasma_czerwona = table2array(tasma_czerwona);
tasma_czarna = table2array(tasma_czarna);
%% Take only second column
tasma_fioletowa = tasma_fioletowa(:,2);
tasma_czerwona = tasma_czerwona(:,2);
tasma_czarna = tasma_czarna(:,2);
%% OBRÓBKA DANYCH
%% Zero crossing    
time = (1:1:10)

tasma_fioletowa_cross = tasma_fioletowa(1:10000,:);
tasma_czerwona_cross = tasma_czerwona(1:10000,:);
tasma_czarna_cross = tasma_czarna(1:10000,:);

first_divide_fioletowa = buffer(tasma_fioletowa_cross, numel(tasma_fioletowa_cross)/10); 
counter_fioletowa = zeros(10,1)
first_divide_czerwona = buffer(tasma_czerwona_cross, numel(tasma_czerwona_cross)/10); 
counter_czerwona = zeros(10,1)
first_divide_czarna = buffer(tasma_czarna_cross, numel(tasma_czarna_cross)/10); 
counter_czarna = zeros(10,1)

for i = 1:10
    for j = 1:999
        if first_divide_fioletowa(j, i) * first_divide_fioletowa(j+1, i) < 0
            counter_fioletowa(i) = counter_fioletowa(i) + 1;
        end
    end
end

for i = 1:10
    for j = 1:999
        if first_divide_czerwona(j, i) * first_divide_czerwona(j+1, i) < 0
            counter_czerwona(i) = counter_czerwona(i) + 1;
        end
    end
end

for i = 1:10
    for j = 1:999
        if first_divide_czarna(j, i) * first_divide_czarna(j+1, i) < 0
            counter_czarna(i) = counter_czarna(i) + 1;
        end
    end
end

figure()
subplot(1, 2, 1)
plot(tasma_fioletowa_cross)
title('Surowy sygnał EMG')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
subplot(1, 2, 2)
bar(time, counter_fioletowa)
title('Częstość występowania amplitudy równej 0 - guma fioletowa')
xlabel('Czas [s]')
ylabel('Ilość przekroczeń zer')
grid on;

figure()
subplot(1, 2, 1)
plot(tasma_czerwona_cross)
title('Surowy sygnał EMG')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
subplot(1, 2, 2)
bar(time, counter_czerwona)
title('Częstość występowania amplitudy równej 0 - guma czerwona')
xlabel('Czas [s]')
ylabel('Ilość przekroczeń zer')
grid on;

figure()
subplot(1, 2, 1)
plot(tasma_czarna_cross)
title('Surowy sygnał EMG')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
subplot(1, 2, 2)
bar(time, counter_czarna)
title('Częstość występowania amplitudy równej 0 - guma czarna')
xlabel('Czas [s]')
ylabel('Ilość przekroczeń zer')
grid on;
%% Clear temporary variables
clear opts

% Fourier Transform
L_fioletowa = length(tasma_fioletowa);
L_czerwona = length(tasma_czerwona);
L_czarna = length(tasma_czarna);

fs = 1000; %sampling frequency
f_fioletowa = fs*(0:(L_fioletowa/2))/L_fioletowa; % FFT frequency from 0 to L/2 data length
f_czerwona = fs*(0:(L_czerwona/2))/L_czerwona;
f_czarna = fs*(0:(L_czarna/2))/L_czarna;

%compute two sided spectrum (-Fmax:Fmax)
p_fioletowa = fft(tasma_fioletowa);
p_czerwona = fft(tasma_czerwona);
p_czarna = fft(tasma_czarna);

%divive by L for normalization of the power of the output 
p_fioletowa = abs(p_fioletowa/L_fioletowa);
p_czerwona = abs(p_czerwona/L_czerwona);
p_czarna = abs(p_czarna/L_czarna);

% compute signal sided spectrum
p_fioletowa=p_fioletowa(1:L_fioletowa/2+1);
p_fioletowa(2:end-1) = 2*p_fioletowa(2:end-1);

p_czerwona=p_czerwona(1:L_czerwona/2+1);
p_czerwona(2:end-1) = 2*p_czerwona(2:end-1);

p_czarna=p_czarna(1:L_czarna/2+1);
p_czarna(2:end-1) = 2*p_czarna(2:end-1);

%Plotting FFT
figure()
subplot(1, 3, 1)
plot(f_fioletowa, p_fioletowa)
xlabel('Częstotliwość [Hz]')
ylabel('Intensywność')
title('FFT (guma fioletowa)')
grid on;

subplot(1, 3, 2)
plot(f_czerwona, p_czerwona)
xlabel('Częstotliwość [Hz]')
ylabel('Intensywność')
title('FFT (guma czerwona)')
grid on;

subplot(1, 3, 3)
plot(f_czarna, p_czarna)
xlabel('Częstotliwość[Hz]')
ylabel('Intensywność')
title('FFT (guma czarna)')
grid on;
%% Rectification
tasma_fioletowa = abs(tasma_fioletowa);
tasma_czerwona = abs(tasma_czerwona);
tasma_czarna = abs(tasma_czarna);
%% RMS Mean Power of signal
envelope_fioletowa = zeros(L_fioletowa, 1);
envelope_czerwona = zeros(L_czerwona, 1);
envelope_czarna = zeros(L_czarna, 1);

window = 100;
envelope_fioletowa = sqrt(movmean(tasma_fioletowa.^2, window));
envelope_czerwona = sqrt(movmean(tasma_czerwona.^2, window));
envelope_czarna = sqrt(movmean(tasma_czarna.^2, window));
%% Normalization with MVC
MVC_fioletowa = max(tasma_fioletowa);
MVC_fioletowa_normalised = zeros(L_fioletowa, 1);
MVC_fioletowa_normalised = envelope_fioletowa./MVC_fioletowa.*100;

MVC_czerwona = max(tasma_czerwona);
MVC_czerwona_normalised = zeros(L_czerwona, 1);
MVC_czerwona_normalised = envelope_czerwona./MVC_czerwona.*100;

MVC_czarna = max(tasma_czarna);
MVC_czarna_normalised = zeros(L_czarna, 1);
MVC_czarna_normalised = envelope_czarna./MVC_czarna.*100;

figure()
subplot(3, 1, 1)
plot(tasma_fioletowa)
hold on;
plot(envelope_fioletowa, 'g')
xlabel("Czas [ms]")
ylabel("Amplituda [μV]")
xlim([0 30000])
title('Normalizacja MVC (guma fioletowa)')
legend('Sygnał EMG', 'Sygnał znormalizowany')

subplot(3, 1, 2)
plot(tasma_czerwona)
hold on;
plot(envelope_czerwona, 'g')
xlabel("Czas [ms]")
ylabel("Amplituda [μV]")
xlim([0 30000])
title('Normalizacja MVC (guma czerwona)')
legend('Sygnał EMG', 'Sygnał znormalizowany')

subplot(3, 1, 3)
plot(tasma_czarna)
hold on;
plot(envelope_czarna, 'g')
xlabel("Czas [ms]")
ylabel("Amplituda [μV]")
xlim([0 30000])
title('Normalizacja MVC (guma czarna)')
legend('Sygnał EMG', 'Sygnał znormalizowany')



%% TASMA-FIOLETOWA
figure()

subplot(3,1,1)
plot(tasma_fioletowa,"b")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z taśmą do ćwiczeń (fioletowa)")
legend("sygnał wyjściowy")
xlim([0 30000])
tasma_fioletowa = abs(tasma_fioletowa);

subplot(3,1,2)
plot(tasma_fioletowa,"b")
xlim([0 30000])
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z taśmą do ćwiczeń (fioletowa)")
legend("moduł z sygnału")
%M1 = sqrt(movmean(tasma_fioletowa,100));
M1 = conv2(tasma_fioletowa, ones(101,1)/101, 'same');
plot(M1,"g")
legend("moduł z sygnału", "filtracja movingAverage")

subplot(3,1,3)
plot(M1,"g")
xlim([0 30000])
title("Zginanie z taśmą do ćwiczeń (fioletowa)")
legend("filtracja movingAverage")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")

max(tasma_fioletowa) %max_amplituda=8210

%% TASMA_CZERWONA
figure()

subplot(3,1,1)
plot(tasma_czerwona,"b")
xlim([0 30000])
legend("sygnał wyjściowy")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z taśmą do ćwiczeń (czerwona)")

subplot(3,1,2)
tasma_czerwona=abs(tasma_czerwona);
plot(tasma_czerwona,"b")
xlim([0 30000])
legend("moduł z sygnału")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
%M2 = movmean(tasma_czerwona,100);
M2 = conv2(tasma_czerwona, ones(101,1)/101, 'same');
plot(M2,"g")
legend("moduł z sygnału", "filtracja movingAverage")
title("Zginanie z taśmą do ćwiczeń (czerwona)")

subplot(3,1,3)
plot(M2,"g")
xlim([0 30000])
legend("filtracja movingAverage")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z taśmą do ćwiczeń (czerwona)")

%% TASMA_CZARNA
figure()

subplot(3,1,1)
plot(tasma_czarna,"b")
xlim([0 30000])
legend("sygnał wyjściowy")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z taśmą do ćwiczeń (czarna)")

subplot(3,1,2)
tasma_czarna=abs(tasma_czarna);
plot(tasma_czarna,"b")
xlim([0 30000])
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
%M2 = movmean(tasma_czarna,100);
M3 = conv2(tasma_czarna, ones(101,1)/101, 'same');
plot(M3,"g")
legend("moduł z sygnału", "filtracja movingAverage")
title("Zginanie z taśmą do ćwiczeń (czarna)")

subplot(3,1,3)
plot(M3,"g")
xlim([0 30000])
legend("filtracja movingAverage")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z taśmą do ćwiczeń (czarna)")

%% Dopasowanie krzywej do sygnałów movingAverage
t1 = linspace(0,30000, length(M1));
% M1 = M1(:,2);

t2 = linspace(0,30000, length(M2))
% M2 = M2(:,2);

t3 = linspace(0,30000, length(M3))
% M3 = M3(:,2);

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( t1, M1 );

% Set up fittype and options.
ft = fittype( 'sin5' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf];
opts.StartPoint = [1177.76924572929 0.00010471975511966 0.305836393117226 440.570813642796 0.00146607657167524 1.01777174276134 522.802100291601 0.00020943951023932 2.15149417742499 311.966256501074 0.00293215314335047 1.43099951180843 158.277951263766 0.00167551608191456 -1.61000350003862];

% Fit model to data.
[fitresult1, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h1 = plot( fitresult1);
legend( h1, 'M1 vs. t', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 't', 'Interpreter', 'none' );
ylabel( 'M1', 'Interpreter', 'none' );
grid on;


%% %% Fit: 'untitled fit 2'.

[xData, yData] = prepareCurveData(t2, M2);

% Set up fittype and options.
ft = fittype( 'sin5' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf];
opts.StartPoint = [647.795990438747 0.00010471975511966 0.0118330965678983 335.860134934129 0.00146607657167524 -1.10638645003117 269.732737546306 0.00020943951023932 1.59760517346566 104.932120096236 0.00293215314335047 2.36446196407868 93.0791517510003 0.00439822971502571 -1.64576597851057];

% Fit model to data.
[fitresult2, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h2 = plot( fitresult2);
legend( h2, 'M2 vs. t2', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 't2', 'Interpreter', 'none' );
ylabel( 'M2', 'Interpreter', 'none' );
grid on;
%% %% Fit: 'untitled fit 3'.
[xData, yData] = prepareCurveData( t3, M3 );

% Set up fittype and options.
ft = fittype( 'sin8' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf];
opts.StartPoint = [871.833518814535 0.00010471975511966 -0.0200203435770756 386.923335166231 0.00020943951023932 1.53901175164781 310.762803871042 0.00125663706143592 1.64651859325003 183.235147698266 0.000418879020478639 2.06622357499311 154.615759657699 0.0010471975511966 1.55235484913363 146.053358387648 0.00146607657167524 -1.60972414035153 125.405971926403 0.00167551608191456 -2.70459984473794 105.625835045466 0.00272271363311115 -1.66358415488271];

% Fit model to data.
[fitresult3, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 3' );
h3 = plot( fitresult3);
legend( h3, 'M3 vs. t3', 'untitled fit 3', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 't3', 'Interpreter', 'none' );
ylabel( 'M3', 'Interpreter', 'none' );
grid on;


%% 

plot( fitresult1, "r")
hold on
plot( fitresult2, "b")
plot( fitresult3, "g")
legend("Taśma fioletowa", "Taśma czerwona", "Taśma czarna")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")

grid on
hold off
