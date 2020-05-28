classdef TransmissionLine
%     TransmissionLine Class containing the geometry and parameters of an
%     overhead Transmission Line (TL) or cable
%         This class contains the following parameters
%         type = 'overhead'|'cable' -> specifies if this TL is an
%         overhead TL or a cable
% 
%         length -> length of this TL in km
% 
%         transposition = 'yes'|'no' -> specifies if the parameters
%         should be transposed after being calculated
% 
%         frequency -> vector containing the frequencies in Hz at which line 
%         parameters are calculated
% 
%         data -> structure containing information about the geometry and
%         properties of this TL as follows.
%         FOR OVERHEAD TRANSMISSION LINES:
%             ===GENERAL===
%             data.comments = 'comments';
%             data.units = 'metric';                     % system of units
%             data.frequency = [60];                     % [1 x freqs] >vector of frequencies
%             data.groundResistivity = 100;              % n (ohm*m)>ground resistivity
%             ===LINE GEOMETRY===
%             data.Geometry.NPhaseBundle = 3;            % n >number of phase conductor/bundles
%             data.Geometry.NGroundBundle = 2;           % n >number of ground conductors/bundles
%             data.Geometry.PhaseNumber = [1 2 3 0 0];   % [1 x phase+ground] >phase corresponding to each phase bundle, 0 is ground
%             data.Geometry.X = [-12 0 12 -8 8];         % [1 x phase+ground] (m)>horizontal position of each conductor from the center of the tower
%             data.Geometry.Ytower = [20 20 20 33 33];   % [1 x phase+ground] (m)>height of each conductor from the center of the tower
%             data.Geometry.Ymin = [20 20 20 33 33];     % [1 x phase+ground] (m)>lowest position of each conductor along the line Ytower-sag
%             data.Geometry.ConductorType = [1 1 1 2 2]; % [1 x phase+ground] >type of conductor/bundle for each phase bundle
%             ===CONDUCTOR AND BUNDLE CHARACTERISTICS===
%             data.Conductors.Diameter = [3.55 1.27];    % [1 x nType] (cm)>conductor outside diameter for each conductor type
%             %ONE OF THE FOLLOWING 3 SHOULD BE PROVIDED TO EVALUATE CONDUCTOR INTERNAL INDUCTANCE
%                 data.Conductors.ThickRatio = [0.37 0.5];   % [1 x nType] >ratio conductor thickness/diameter, 0.5 is solid conductor, best for obtaining parameters at several frequencies.For Aluminum Cable Steel Reinforced (ACSR) conductors, you can ignore the steel core and consider a hollow aluminum conductor (typical T/D ratios comprised between 0.3 and 0.4)
%                 data.Conductors.GMR = [];                  % [1 x nType] (in)>Geometric Mean Radius of each single unbundled conductor 
%                 data.Conductors.Xa = [];                   % [1 x nType] (ohm/km)>Reactance at one-meter spacing of each single unbundled conductor
%             data.Conductors.Res = [0.0430 3.1060];     % [1 x nType] (ohm/km)>conductor DC resistance
%             data.Conductors.Mur = [1 1];               % [1 x nType] >conductor relative permeability, µr = 1.0 for nonmagnetic conductors (aluminum, copper)
%             data.Conductors.Nconductors = [4 1];       % [1 x nType] >number of conductors per bundle
%             data.Conductors.BundleDiameter = [65 0];   % [1 x nType] (cm)>bundle diameter, assuming that the subconductors are assumed to be evenly spaced on a circle.
%             data.Conductors.AngleConductor1 = [45 0];  % [1 x nType] (deg)>angle of conductor 1
%             data.Conductors.skinEffect = 'yes';        % 'yes'/'no' >include conductor skin effect
%         FOR CABLES*********************************************************
%             ===GENERAL===
%             data.N = 4;                % n >number of cables
%             data.f = [16.7];           % [1 x freqs] >vector of frequencies
%             data.rho_e = 100;          % n (ohm*m)>ground resistivity
%             data.GMD_phi = 0.2470;     % n (m)>Geometric Mean Distance(GMD) between the phase conductors
%             ===PHASE CONDUCTOR===
%             data.n_ba = 58;            % n >the number of strands contained in the phase conductor.
%             data.d_ba = 0.0027;        % n (m)>the diameter of one strand
%             data.rho_ba = 1.78e-08;    % n (ohm*m)>DC resistivity of phase conductor
%             data.mu_r_ba = 1;          % n >relative permeability of the conductor material.
%             data.D_a = 0.0209;         % n (m)>external diameter of phase conductor 
%             ===SCREEN PROPERTIES===
%             data.rho_x = 1.7800e-08;   % n (ohm*m)>DC resistivity of the screen
%             data.S_x = 1.6900e-04;     % n (m^2)>total section of the screen
%             data.d_x = 0.0658;         % n (m)>internal diameter of the screen 
%             data.D_x = 0.0698;         % n (m)>external diameter of the screen
%             ===PHASE-SCREEN INSULATOR===
%             data.epsilon_iax = 2.3;    % n >relative permittivity of the phase-screen insulator material.
%             data.d_iax = 0.0233;       % n (m)>phase-screen insulator internal diameter
%             data.D_iax = 0.0606;       % n (m)>phase-screen insulator external diameter
%             ===OUTER SCREEN INSULATOR===
%             data.epsilon_ixe = 2.25;   % n >relative permittivity of the outer screen insulator material
%             data.d_ixe = 0.0698;       % n (m)>outer screen insulator internal diameter
%             data.D_ixe = 0.0778;       % n (m)>outer screen insulator external diameter
%         
%         pulImpedance        % [#phase #phase #freq] (ohm/km)>longitudinal pul impedance of the transmission line
%         
%         pulAdmittance       % [#phase #phase #freq] (S/km)>longitudinal pul admittance of the transmission line
%         
%         pulR                % [#phase #phase #freq] (ohm/km)>longitudinal pul admittance of the transmission line
%         
%         pulL                % [#phase #phase #freq] (H/km)>longitudinal pul admittance of the transmission line
%         
%         pulC                % [#phase #phase #freq] (F/km)>longitudinal pul admittance of the transmission line
%     
%     *For each parameter, n represents a single numeric value, [] contains 
%     the dimensions at which parameters should be given. In parenthesis are 
%     the units at which the parameters should be given. > shows a 
%     short description of the parameter
% 
%     So far, we added the following overhead transmission line presets:
%     For 'overhead' lines, we have added the following presets:
%     TL = TransmissionLine('overhead', 100, 'default1') -> 440kV single-phase transmission line adapted from [1]
%     TL = TransmissionLine('overhead', 100, 'asymmetrical2') -> 440kV two-phase asymmetrical transmission line adapted from [1]
%     TL = TransmissionLine('overhead', 100, 'symmetrical2') -> 440kV two-phase transmission line with vertical symmetry adapted from [1]
%     TL = TransmissionLine('overhead', 100, 'symmetrical3') -> 440kV three-phase transmission line with vertical symmetry adapted from [1]
%     TL = TransmissionLine('overhead', 100, 'symmetrical3noground') -> 440kV three-phase transmission line with vertical symmetry and no ground wires
%     TL = TransmissionLine('overhead', 100, 'half3p4'|'vertical3') -> 345kV three-phase transmission line with vertical geometry adapted from [2]
%     TL = TransmissionLine('overhead', 100, '3p1'|'asymmetrical3') -> 345kV three-phase transmission line with asymmetrical geometry adapted from [2]
%     For cables, we have only one added one preset so far.
%     TL = TransmissionLine('cable', 100, 'default1')
    
    properties
        type                % 'overhead','cable' >Define type of transmission line
        length              % n (km)>length of the transmission line
        transposition          % true,false >indicates if the line is transposition or not
        frequency           % [#freq 1] (Hz)>frequency at which the transmission line parameters are calculated
        
        data                % struc >structure containing the geometry and properties of the transmission line
        
        pulImpedance        % [#phase #phase #freq] (ohm/km)>longitudinal pul impedance of the transmission line
        pulAdmittance       % [#phase #phase #freq] (S/km)>longitudinal pul admittance of the transmission line
        pulR                % [#phase #phase #freq] (ohm/km)>longitudinal pul admittance of the transmission line
        pulL                % [#phase #phase #freq] (H/km)>longitudinal pul admittance of the transmission line
        pulC                % [#phase #phase #freq] (F/km)>longitudinal pul admittance of the transmission line
        
    end
%% CONSTRUCTOR
    methods
        function this = TransmissionLine(type, length, option)
        %TransmissionLine Summary of this function goes here
        %   Detailed explanation goes here
        
            %% Pre Initialization %%
            this.type = type;
            this.length = length;
            this.transposition = false;
            if nargin == 2
                switch lower(this.type)
                    case 'overhead'
                        option = 'default3';
                    case 'cable'
                        option = 'default3';
                    otherwise
                end
            end

            %% Post Initialization %%
            switch lower(this.type)
                case 'overhead'
                    LDATA = power_lineparam('new');
                    LDATA.units = 'metric';
                    LDATA.frequency = [];
                    LDATA.groundResistivity = 100;
                    LDATA.Conductors.skinEffect = 'yes';
                    switch lower(option)
                        case {'default1'}
                            disp('adapted from a 440kV Transmission Line:') %TAVARES MC 1999
                            disp('Phase conductors: One bundle of 4 Bersfort ACSR 1355 MCM conductors')
                            disp('no ground wires')
                            LDATA.comments = option;
                            %%LINE GEOMETRY
                            LDATA.Geometry.NPhaseBundle =  1;% #conductors
                            LDATA.Geometry.NGroundBundle = 0;% #ground wires
                            LDATA.Geometry.PhaseNumber =    [ 1      ]; % [1 x phase+ground] 
                            LDATA.Geometry.X =              [ 0      ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ytower =         [ 21.33  ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ymin =           [ 21.33  ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.ConductorType =  [ 1      ]; % [1 x phase+ground] 
                            %%CONDUCTOR AND BUNDLE CHARACTERISTICS
                            LDATA.Conductors.Diameter =        [3.55   ]; % [1 x nType] (cm)>external diameter
                            LDATA.Conductors.ThickRatio =      [0.37   ]; % [1 x nType] >thickness/diameter
                            LDATA.Conductors.Res =             [0.0430 ]; % [1 x nType] (ohm/km)>DC resistance
                            LDATA.Conductors.Mur =             [1      ]; % [1 x nType] >relative permeability
                            LDATA.Conductors.Nconductors =     [4      ]; % [1 x nType] >conductors per bundle
                            LDATA.Conductors.BundleDiameter =  [65     ]; % [1 x nType] (cm)>bundle diameter
                            LDATA.Conductors.AngleConductor1 = [45     ]; % [1 x nType] (deg)>angle of conductor 1
                        case {'default2','asymmetrical2'}
                            disp('adapted from a 440kV Transmission Line:') %TAVARES MC 1999
                            disp('Phase conductors: Two bundles of 4 Bersfort ACSR 1355 MCM conductors')
                            disp('no ground wires')
                            LDATA.comments = option;
                            %%LINE GEOMETRY
                            LDATA.Geometry.NPhaseBundle =  2;% #conductors
                            LDATA.Geometry.NGroundBundle = 0;% #ground wires
                            LDATA.Geometry.PhaseNumber =    [ 1      2      ]; % [1 x phase+ground] 
                            LDATA.Geometry.X =              [ 0     -9.14   ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ytower =         [ 21.33  17.37  ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ymin =           [ 21.33  17.37  ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.ConductorType =  [ 1      1      ]; % [1 x phase+ground] 
                            %%CONDUCTOR AND BUNDLE CHARACTERISTICS
                            LDATA.Conductors.Diameter =        [3.55   ]; % [1 x nType] (cm)>external diameter
                            LDATA.Conductors.ThickRatio =      [0.37   ]; % [1 x nType] >thickness/diameter
                            LDATA.Conductors.Res =             [0.0430 ]; % [1 x nType] (ohm/km)>DC resistance
                            LDATA.Conductors.Mur =             [1      ]; % [1 x nType] >relative permeability
                            LDATA.Conductors.Nconductors =     [4      ]; % [1 x nType] >conductors per bundle
                            LDATA.Conductors.BundleDiameter =  [65     ]; % [1 x nType] (cm)>bundle diameter
                            LDATA.Conductors.AngleConductor1 = [45     ]; % [1 x nType] (deg)>angle of conductor 1
                        case {'symmetrical2'}
                            disp('adapted from a 440kV Transmission Line:') %TAVARES MC 1999
                            disp('Phase conductors: Three bundles of 4 Bersfort ACSR 1355 MCM conductors')
                            disp('Ground wires:     two 1/2 inch-diameter steel ground wires')
                            LDATA.comments = option;
                            %%LINE GEOMETRY
                            LDATA.Geometry.NPhaseBundle =  2;% #conductors
                            LDATA.Geometry.NGroundBundle = 0;% #ground wires
                            LDATA.Geometry.PhaseNumber =    [  1      2     ]; % [1 x phase+ground] 
                            LDATA.Geometry.X =              [ -9.14   9.14  ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ytower =         [  17.37  17.37 ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ymin =           [  17.37  17.37 ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.ConductorType =  [  1      1     ]; % [1 x phase+ground] 
                            %%CONDUCTOR AND BUNDLE CHARACTERISTICS
                            LDATA.Conductors.Diameter =        [3.55   ]; % [1 x nType] (cm)>external diameter
                            LDATA.Conductors.ThickRatio =      [0.37   ]; % [1 x nType] >thickness/diameter
                            LDATA.Conductors.Res =             [0.0430 ]; % [1 x nType] (ohm/km)>DC resistance
                            LDATA.Conductors.Mur =             [1      ]; % [1 x nType] >relative permeability
                            LDATA.Conductors.Nconductors =     [4      ]; % [1 x nType] >conductors per bundle
                            LDATA.Conductors.BundleDiameter =  [65     ]; % [1 x nType] (cm)>bundle diameter
                            LDATA.Conductors.AngleConductor1 = [45     ]; % [1 x nType] (deg)>angle of conductor 1
                        case {'default3','symmetrical3'}
                            disp('440kV Transmission Line:') %TAVARES MC 1999
                            disp('Phase conductors: Three bundles of 4 Bersfort ACSR 1355 MCM conductors')
                            disp('Ground wires:     Two 1/2 inch-diameter steel ground wires')
                            LDATA.comments = option;
                            %%LINE GEOMETRY
                            LDATA.Geometry.NPhaseBundle =  3;% #conductors
                            LDATA.Geometry.NGroundBundle = 2;% #ground wires
                            LDATA.Geometry.PhaseNumber =    [ 1      2      3      0      0    ]; % [1 x phase+ground] 
                            LDATA.Geometry.X =              [ 0     -9.14   9.14  -5.02   5.02 ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ytower =         [ 21.33  17.37  17.37  26.66  26.66]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ymin =           [ 21.33  17.37  17.37  26.66  26.66]; % [1 x phase+ground] (m)
                            LDATA.Geometry.ConductorType =  [ 1      1      1      2      2    ]; % [1 x phase+ground] 
                            %%CONDUCTOR AND BUNDLE CHARACTERISTICS
                            LDATA.Conductors.Diameter =        [3.55   1.27  ]; % [1 x nType] (cm)>external diameter
                            LDATA.Conductors.ThickRatio =      [0.37   0.50  ]; % [1 x nType] >thickness/diameter
                            LDATA.Conductors.Res =             [0.0430 3.1060]; % [1 x nType] (ohm/km)>DC resistance
                            LDATA.Conductors.Mur =             [1      1     ]; % [1 x nType] >relative permeability
                            LDATA.Conductors.Nconductors =     [4      1     ]; % [1 x nType] >conductors per bundle
                            LDATA.Conductors.BundleDiameter =  [65     0     ]; % [1 x nType] (cm)>bundle diameter
                            LDATA.Conductors.AngleConductor1 = [45     0     ]; % [1 x nType] (deg)>angle of conductor 1
                        case {'symmetrical3noground'}
                            disp('440kV Transmission Line:') %TAVARES MC 1999
                            disp('Phase conductors: Three bundles of 4 Bersfort ACSR 1355 MCM conductors')
                            disp('no ground wires')
                            LDATA.comments = option;
                            %%LINE GEOMETRY
                            LDATA.Geometry.NPhaseBundle =  3;% #conductors
                            LDATA.Geometry.NGroundBundle = 0;% #ground wires
                            LDATA.Geometry.PhaseNumber =    [ 1      2      3     ]; % [1 x phase+ground] 
                            LDATA.Geometry.X =              [ 0     -9.14   9.14  ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ytower =         [ 21.33  17.37  17.37 ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ymin =           [ 21.33  17.37  17.37 ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.ConductorType =  [ 1      1      1     ]; % [1 x phase+ground] 
                            %%CONDUCTOR AND BUNDLE CHARACTERISTICS
                            LDATA.Conductors.Diameter =        [3.55   ]; % [1 x nType] (cm)>external diameter
                            LDATA.Conductors.ThickRatio =      [0.37   ]; % [1 x nType] >thickness/diameter
                            LDATA.Conductors.Res =             [0.0430 ]; % [1 x nType] (ohm/km)>DC resistance
                            LDATA.Conductors.Mur =             [1      ]; % [1 x nType] >relative permeability
                            LDATA.Conductors.Nconductors =     [4      ]; % [1 x nType] >conductors per bundle
                            LDATA.Conductors.BundleDiameter =  [65     ]; % [1 x nType] (cm)>bundle diameter
                            LDATA.Conductors.AngleConductor1 = [45     ]; % [1 x nType] (deg)>angle of conductor 1
                        case {'half3p4','vertical3'}
                            disp('adapted from a 345kV Transmission Line (half 3p4):') %TL reference book pg. 56
                            disp('Phase conductors: Three bundles of 4 Bersfort ACSR 1355 MCM conductors')
                            disp('Ground wires:     one 1/2 inch-diameter steel ground wires')
                            LDATA.comments = option;
                            %%LINE GEOMETRY
                            LDATA.Geometry.NPhaseBundle =  3;% #conductors
                            LDATA.Geometry.NGroundBundle = 0;% #ground wires
                            LDATA.Geometry.PhaseNumber =    [ 1      2      3    ]; % [1 x phase+ground] 
                            LDATA.Geometry.X =              [ 3.05   3.05   3.05 ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ytower =         [ 26     30.87  35.74]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ymin =           [ 26     30.87  35.74]; % [1 x phase+ground] (m)
                            LDATA.Geometry.ConductorType =  [ 1      1      1    ]; % [1 x phase+ground] 
                            %%CONDUCTOR AND BUNDLE CHARACTERISTICS
                            LDATA.Conductors.Diameter =        [3.55   ]; % [1 x nType] (cm)>external diameter
                            LDATA.Conductors.ThickRatio =      [0.37   ]; % [1 x nType] >thickness/diameter
                            LDATA.Conductors.Res =             [0.0430 ]; % [1 x nType] (ohm/km)>DC resistance
                            LDATA.Conductors.Mur =             [1      ]; % [1 x nType] >relative permeability
                            LDATA.Conductors.Nconductors =     [4      ]; % [1 x nType] >conductors per bundle
                            LDATA.Conductors.BundleDiameter =  [65     ]; % [1 x nType] (cm)>bundle diameter
                            LDATA.Conductors.AngleConductor1 = [45     ]; % [1 x nType] (deg)>angle of conductor 1
                        case {'3p1','asymmetrical3'}
                            disp('345kV Transmission Line (3p1):') %%TL reference book pg. 56
                            disp('Phase conductors: Three bundles of 4 Bersfort ACSR 1355 MCM conductors')
                            disp('Ground wires:     one 1/2 inch-diameter steel ground wires')
                            LDATA.comments = option;
                            %%LINE GEOMETRY
                            LDATA.Geometry.NPhaseBundle =  3;% #conductors
                            LDATA.Geometry.NGroundBundle = 0;% #ground wires
                            LDATA.Geometry.PhaseNumber =    [ 1      2      3    ]; % [1 x phase+ground] 
                            LDATA.Geometry.X =              [ 2.74  -2.74   2.74 ]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ytower =         [ 23.16  19.55  16.15]; % [1 x phase+ground] (m)
                            LDATA.Geometry.Ymin =           [ 23.16  19.55  16.15]; % [1 x phase+ground] (m)
                            LDATA.Geometry.ConductorType =  [ 1      1      1    ]; % [1 x phase+ground] 
                            %%CONDUCTOR AND BUNDLE CHARACTERISTICS
                            LDATA.Conductors.Diameter =        [3.55   ]; % [1 x nType] (cm)>external diameter
                            LDATA.Conductors.ThickRatio =      [0.37   ]; % [1 x nType] >thickness/diameter
                            LDATA.Conductors.Res =             [0.0430 ]; % [1 x nType] (ohm/km)>DC resistance
                            LDATA.Conductors.Mur =             [1      ]; % [1 x nType] >relative permeability
                            LDATA.Conductors.Nconductors =     [4      ]; % [1 x nType] >conductors per bundle
                            LDATA.Conductors.BundleDiameter =  [65     ]; % [1 x nType] (cm)>bundle diameter
                            LDATA.Conductors.AngleConductor1 = [45     ]; % [1 x nType] (deg)>angle of conductor 1
                        case ''
                        otherwise
                            error('invalid line option')
                    end
                    this.data = LDATA;
                case 'cable'
                    CDATA = power_cable_data;
                    this.data = CDATA;
                otherwise
            end
            
        end
    end
    
%     methods
%         function obj = untitled2(inputArg1,inputArg2)
%             %UNTITLED2 Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.Property1 = inputArg1 + inputArg2;
%         end
%         
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
%     end
    
%% ************************************************************************
%**************************************************************************
%******************************STATIC METHODS******************************
%**************************************************************************
%**************************************************************************
%     methods (Static)
% %         function properties = bundleProperties(option)
% %             %cableProperties
% %             switch lower(option)
% %         end
%     end
    
    
end

