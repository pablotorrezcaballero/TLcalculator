%THIS IS AN EXAMPLE OF A SCRIPT TO CALCULATE TRANSMISSION LINE PARAMETERS

% The following line of code displays a brief description of the class
% TransmissionLine. Run it to show
help TransmissionLine %


% First we choose a transmission line preset (see TransmissionLine class description)
% Available presets are shown at the bottom of the TransmissionLine help above
% For example, the following lines, generate data for different transmission lines as
% specified on the TransmissionLine class description. Uncomment to show
% TL1 = TransmissionLine('overhead', 100, 'symmetrical3noground'); %overhead, 100km, 440kV three-phase transmission line with vertical symmetry and no ground wires
% TL1 = TransmissionLine('overhead', 100, 'symmetrical3'); %overhead, 100km, 440kV three-phase transmission line with vertical symmetry and 2 ground wires
% TL1 = TransmissionLine('cable', 100, 'default'); %default, 100km, cable
TL1 = TransmissionLine('overhead', 100, 'symmetrical3');

% after a preset is chosen, the line geometry and properties are available
% in the instance TL1. The following lines of code show the geometry and 
% properties of the preset that can be further customized. Uncomment to show
% TL1.data
% TL1.data.Geometry
% TL1.data.Conductors

% Then we specify at which frequencies we want to calculate parameters e.g. 
% for 1000 exponentially distributed frequency points between 0.01 and 1 MHz:
frequency = logspace(-2,6,1000);

% Once the line properties and geometry had been established, then the 
% line parameters for the frequencies specified are generated as follows
TL1 = TL1.calculateParameters(frequency);

% The calculated parameters are available in arrays as follows
% TL1.pulImpedance        [#phase #phase #freq] (ohm/km)>longitudinal pul impedance of the transmission line
% TL1.pulAdmittance       [#phase #phase #freq] (S/km)>longitudinal pul admittance of the transmission line
% TL1.pulR                [#phase #phase #freq] (ohm/km)>longitudinal pul admittance of the transmission line
% TL1.pulL                [#phase #phase #freq] (H/km)>longitudinal pul admittance of the transmission line
% TL1.pulC                [#phase #phase #freq] (F/km)>longitudinal pul admittance of the transmission line
% *For each parameter, n represents a single numeric value, [] contains 
% the dimensions of the array. In parenthesis are the units at which the 
% parameters are calculated. > shows a short description of the parameter

%% plotting impedances
figure(1);clf;
for iPhase = 1:size(TL1.pulR, 1)
    selfR = TL1.pulR(iPhase,iPhase,:);
    selfL = TL1.pulL(iPhase,iPhase,:);
    
    subplot(2,1,1);
    semilogx(TL1.frequency, selfR(:), 'DisplayName', ['Phase ' num2str(iPhase) ' self resistance']); hold on
    ylabel('\Omega/km')

    subplot(2,1,2); 
    semilogx(TL1.frequency, selfL(:), 'DisplayName', ['Phase ' num2str(iPhase) ' self inductance']); hold on
    ylabel('H/km')
end
subplot(2,1,1);
legend('show')
subplot(2,1,2);
legend('show')