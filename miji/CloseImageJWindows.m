function [] = CloseImageJWindows()

        % close existing windows -- use try/catch because MIJ.getListImages
        % returns an error if no images are open
        try
            pause(.2)
            if length(MIJ.getListImages)>0
                if ~exist('IJ')
                    import ij.*;
                    disp('importing ij')
                end
                for i=1:length(MIJ.getListImages);
                    IJ.run('Close')
                end
            end              
        catch

        end

end

