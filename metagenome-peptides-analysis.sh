#!/bin/bash

# Directory where your metagenome FASTA files are located
input_dir="metagenomes"
# Directory where Macrel results will be stored
output_dir="macrel_output"
# Directory where consolidated results from all metagenomes will be stored
consolidated_dir="consolidated_predictions"

# Create output directories if they do not exist
mkdir -p $output_dir
mkdir -p $consolidated_dir

# Final file to consolidate all peptides and their predictions
all_peptides="$consolidated_dir/all_peptides_predictions.txt"

# Initialize the consolidated file with a header
echo -e "Metagenome\tAccess\tSequence\tAMP_Family\tAMP_Probability\tHemolytic\tHemolytic_Probability\tNonHemolytic_Probability" > $all_peptides

# Iterate over FASTA files in the input directory
for fasta in $input_dir/*.fasta; do

  # Extract the base filename
  base=$(basename $fasta .fasta)

  # Define the output directory for each metagenome
  sample_output_dir="$output_dir/$base"

  # Run Macrel contigs
  macrel contigs \
    --fasta $fasta \
    --output $sample_output_dir \
    --tag $base \
    --threads 24  # Adjust the number of threads according to your system

  # Check if Macrel executed successfully
  if [ $? -eq 0 ]; then
    echo "Analysis of $base completed successfully."

    # Define prediction files
    prediction_gz="$sample_output_dir/${base}.prediction.gz"
    prediction_txt="$sample_output_dir/${base}.prediction.txt"

    if [[ -f "$prediction_gz" ]]; then
      echo "Decompressing file: $prediction_gz"
      gzip -d -c "$prediction_gz" > "$prediction_txt"

      if [[ -f "$prediction_txt" ]]; then
        echo "File successfully decompressed."

        # Check if the file contains more than just the header
        if [[ $(wc -l < "$prediction_txt") -gt 1 ]]; then

          # Append predictions to consolidated file (skip header)
          tail -n +2 "$prediction_txt" | while read line; do
            if [[ $line != Access* ]]; then  # Avoid adding repeated headers
              echo -e "$base\t$line" >> $all_peptides
            fi
          done

        else
          echo "Prediction file is empty or contains only headers. $base will not be added to the consolidated file."
        fi

      else
        echo "Failed to decompress the prediction file."
      fi

    else
      echo "Prediction .gz file not found for $base."
    fi

  else
    echo "An error occurred while analyzing $base."
  fi

done

echo "All analyses have been completed."
echo "Consolidated peptides stored in: $all_peptides"


