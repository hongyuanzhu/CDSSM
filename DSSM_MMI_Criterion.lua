local DSSM_MMI_Criterion, parent = torch.class('nn.DSSM_MMI_Criterion', 'nn.Criterion')

local Calculate_Alpha = require 'Calculate_Alpha'

function DSSM_MMI_Criterion:__init(batch_size, nTrail)
    parent.__init(self)
    -- do negative sampling
    local negtive_array = torch.IntTensor(batch_size * nTrail)

    for i = 1, nTrail do
        local randpos = torch.random(0.8*batch_size) + math.floor(0.1 * batch_size)
        for k = 1, batch_size do
            local bs = (randpos + k) % batch_size + 1
            negtive_array[(i-1)*batch_size + k] = bs
        end
    end

    -- concatinate with the postive.
    local postive_array = torch.range(1,batch_size):type('torch.IntTensor')
    self.D_sampling_array = torch.cat(postive_array, negtive_array)
    self.Q_sampling_array = torch.repeatTensor(postive_array, nTrail+1)
    self.gradInput = {torch.Tensor(), torch.Tensor()}
end

function DSSM_MMI_Criterion:updateOutput(input)
    local Q_input, D_input = input[1], input[2]
    -- 1: calculate the cosine distance for positive and negtive array
    local alpha = Calculate_Alpha.calCosDist({Q_input, D_input, self.Q_sampling_array, self.D_sampling_array})
    -- 2: calculate the alpha

    -- 3: calculate the loss
    return alpha

end


function DSSM_MMI_Criterion:updateGradInput(input)


end
