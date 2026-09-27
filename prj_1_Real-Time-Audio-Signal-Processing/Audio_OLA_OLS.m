clc;
clear;
close all;

disp('============================================================');
disp(' LINEAR CONVOLUTION USING OVERLAP-ADD / OVERLAP-SAVE');
disp('============================================================');

%% ===== Step 1: Input Signal =====
disp('Choose Input Signal Type:');
disp(' 1. Load Audio File (.wav or .mp3)');
disp(' 2. Manual Entry');

inputChoice = input('Enter your choice (1 or 2): ');

if inputChoice == 1
    [fileName, filePath] = uigetfile({'*.wav;*.mp3'}, 'Select Audio File');

    if isequal(fileName, 0)
        error('No file selected.');
    end

    fullPath = fullfile(filePath, fileName);
    [inputSignal, Fs] = audioread(fullPath);

    inputSignal = inputSignal(1:min(end, Fs*30), :);

    if size(inputSignal,2) == 2
        inputSignal = mean(inputSignal,2);
    end

    inputSignal = inputSignal(:)';
    inputLength = length(inputSignal);
    timeAxisInput = (0:inputLength-1)/Fs;

    figure;
    plot(timeAxisInput, inputSignal);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Original Audio Signal');
    grid on;

else
    inputSignal = input('Enter input sequence x[n]: ');
    Fs = 1000;
    inputLength = length(inputSignal);
end

%% ===== Step 2: Impulse Response =====
if inputChoice == 1
    disp('Select Impulse Response Type:');
    disp(' 1. Built-in Reverb');
    disp(' 2. Manual Input');

    hChoice = input('Enter option: ');

    if hChoice == 1
        h = [0.9, zeros(1,1000), 0.6, zeros(1,1200), 0.3];
    else
        h = input('Enter impulse response h[n]: ');
    end

else
    h = input('Enter impulse response h[n]: ');
end

M = length(h);

%% ===== Step 3: Block Length =====
L = inputLength + 1;

while L > inputLength
    L = input(['Enter block length L (< ', num2str(inputLength), '): ']);

    if L > inputLength
        disp('Block length must be smaller than input signal length.');
    end
end

N = L + M - 1;
totalConvLength = inputLength + M - 1;
nBlocks = ceil(inputLength / L);

hPadded = [h, zeros(1, N-M)];

%% ===== Step 4: Overlap-Add =====
tic;

Y_add = zeros(1, totalConvLength);

for k = 1:nBlocks

    si = (k-1)*L + 1;
    ei = min(si+L-1, inputLength);

    currentBlock = inputSignal(si:ei);
    currentBlock = [currentBlock, ...
        zeros(1, N - length(currentBlock))];

    Y = cconv(currentBlock, hPadded, N);

    outEnd = min(si+N-1, totalConvLength);

    Y_add(si:outEnd) = Y_add(si:outEnd) + ...
        Y(1:(outEnd-si+1));

end

timeOLA = toc;

%% ===== Step 5: Overlap-Save =====
tic;

Y_save = zeros(1, totalConvLength);

for k = 1:nBlocks

    si = (k-1)*L + 1;
    ei = min(si+L-1, inputLength);

    block = inputSignal(si:ei);

    if k == 1

        segment = [zeros(1, M-1), block];

    else

        overlap = inputSignal(max(si-M+1,1):si-1);

        if length(overlap) < M-1
            overlap = [zeros(1, M-1-length(overlap)), overlap];
        end

        segment = [overlap, block];

    end

    segment = [segment, zeros(1, N - length(segment))];

    Yseg = cconv(segment, hPadded, N);

    outStart = si;
    outEnd = min(si+L-1, totalConvLength);

    Y_save(outStart:outEnd) = ...
        Yseg(M:M+outEnd-outStart);

end

timeOLS = toc;

%% ===== Step 6: Efficiency Comparison =====
disp('============================================================');
disp('Efficiencies of Overlap Add and Overlap Save (seconds):');

disp(['Overlap-Add: ', num2str(timeOLA)]);
disp(['Overlap-Save: ', num2str(timeOLS)]);

if timeOLA < timeOLS
    disp('Result: Overlap Add is faster.');

elseif timeOLS < timeOLA
    disp('Result: Overlap Save is faster.');

else
    disp('Result: Both methods are equally fast.');
end

disp('============================================================');

%% ===== Step 7: Output Selection and Display =====
opt = 0;

while ~ismember(opt, [1 2])

    disp('Select output:');
    disp('1. Overlap-Add Output');
    disp('2. Overlap-Save Output');

    opt = input('Enter option: ');

    if opt == 1
        finalOutput = Y_add;

    elseif opt == 2
        finalOutput = Y_save;

    else
        disp('Enter a valid option');
    end

end

timeAxisOutput = (0:length(finalOutput)-1)/Fs;

figure;
plot(timeAxisOutput, finalOutput);
xlabel('Time (s)');
ylabel('Amplitude');
title('Modified Signal');
grid on;

%% ===== Step 8: Plot Results =====
figure;

subplot(3,1,1);
plot(inputSignal);
title('Input Signal');

subplot(3,1,2);
plot(h);
title('Impulse Response');

subplot(3,1,3);
plot(finalOutput);
title('Convolved Output');
xlabel('Samples');
ylabel('Amplitude');

%% ===== Step 9: Output Display =====
opt = 0;

while ~ismember(opt, [1 2])

    disp('Select output to display:');
    disp('1. Overlap-Add Output');
    disp('2. Overlap-Save Output');

    opt = input('Enter option: ');

end

if opt == 1
    finalOutput = Y_add;
else
    finalOutput = Y_save;
end

%% ===== Step 10: Playback for Audio Input Only =====
if inputChoice == 1

    while true

        inp = input('Play modified:1, Play original:2, End:3: ');

        if inp == 1
            sound(finalOutput, Fs);

        elseif inp == 2
            sound(inputSignal, Fs);

        else
            break;
        end

    end

else

    disp('Input Signal:');
    disp(inputSignal);

    disp('Impulse Response:');
    disp(h);

    disp('Convolved Output:');
    disp(finalOutput);

end