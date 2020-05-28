function this = calculateParameters(this, frequency)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
frequency = frequency(:);
switch lower(this.type)
    case 'overhead'
        LDATA = this.data;
        
        this.pulImpedance = zeros(LDATA.Geometry.NPhaseBundle, LDATA.Geometry.NPhaseBundle, numel(frequency));
        this.pulAdmittance = zeros(LDATA.Geometry.NPhaseBundle, LDATA.Geometry.NPhaseBundle, numel(frequency));
        this.pulR = zeros(LDATA.Geometry.NPhaseBundle, LDATA.Geometry.NPhaseBundle, numel(frequency));
        this.pulL = zeros(LDATA.Geometry.NPhaseBundle, LDATA.Geometry.NPhaseBundle, numel(frequency));
        this.pulC = zeros(LDATA.Geometry.NPhaseBundle, LDATA.Geometry.NPhaseBundle, numel(frequency));

        for index = 1:numel(frequency)
            LDATA.frequency = frequency(index);
            parameters = power_lineparam(LDATA);
            
            this.pulImpedance(:,:,index) = parameters.R + 1i*2*pi*frequency(index)*parameters.L;
            this.pulAdmittance(:,:,index) = 1i*2*pi*frequency(index)*parameters.C;
            this.pulR(:,:,index) = parameters.R;
            this.pulL(:,:,index) = parameters.L;
            this.pulC(:,:,index) = parameters.C;
        end
        
        % if this.transposed
        %     transpose
        % end
    case 'cable'
        CDATA = this.data;
        
        this.pulImpedance = zeros(2*CDATA.N, 2*CDATA.N, numel(frequency));
        this.pulAdmittance = zeros(2*CDATA.N, 2*CDATA.N, numel(frequency));
        this.pulR = zeros(2*CDATA.N, 2*CDATA.N, numel(frequency));
        this.pulL = zeros(2*CDATA.N, 2*CDATA.N, numel(frequency));
        this.pulC = zeros(2*CDATA.N, 2*CDATA.N, numel(frequency));
        
        for index = 1:numel(frequency)
            CDATA.frequency = frequency(index);
            [Rx,Lx,Cx,Zx] = power_cableparam(CDATA);
            
            R_cable = Rx.ab*ones(2*CDATA.N);
            L_cable = Lx.ab*ones(2*CDATA.N);
            Z_cable = Zx.ab*ones(2*CDATA.N);
            C_cable = zeros(2*CDATA.N);
            for subindex = 1:2:2*CDATA.N
                R_cable(subindex:subindex+1,subindex:subindex+1) = [Rx.aa Rx.ax;Rx.ax Rx.xx];
                L_cable(subindex:subindex+1,subindex:subindex+1) = [Lx.aa Lx.ax;Lx.ax Lx.xx];
                Z_cable(subindex:subindex+1,subindex:subindex+1) = [Zx.aa Zx.ax;Zx.ax Zx.xx];
                C_cable(subindex:subindex+1,subindex:subindex+1) = [Cx.ax  -Cx.ax ; -Cx.ax  (Cx.xe+Cx. ax)];
            end
            
            this.pulImpedance(:,:,index) = Z_cable;
            this.pulAdmittance(:,:,index) = 1i*2*pi*frequency(index)*C_cable;
            this.pulR(:,:,index) = R_cable;
            this.pulL(:,:,index) = L_cable;
            this.pulC(:,:,index) = C_cable;
        end
    otherwise
end

this.frequency = frequency(:);
end

