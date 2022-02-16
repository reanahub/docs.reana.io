# Serial

The Serial workflow system is using the sequence workflow pattern where each
computational step can run in a different containerised environment and the
outputs of previous steps are passed along as inputs to later steps. The next
step always depends on the previous step having already been completed.
