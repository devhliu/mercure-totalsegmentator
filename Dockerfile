FROM continuumio/miniconda3

# make mercure-totalsegmentator app directory
RUN mkdir -m777 /app
WORKDIR /app
ADD docker-entrypoint.sh ./
ADD mercure-totalsegmentator ./mercure-totalsegmentator
RUN chmod 777 ./docker-entrypoint.sh

RUN conda create -n env python=3.9
RUN echo "source activate env" > ~/.bashrc
ENV PATH /opt/conda/envs/env/bin:$PATH
RUN chmod -R 777 /opt/conda/envs

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y git build-essential cmake pigz
RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y libsm6 libxrender-dev libxext6 ffmpeg
RUN apt-get install unzip

ADD environment.yml ./
RUN conda env create -f ./environment.yml

# Pull the environment name out of the environment.yml
RUN echo "source activate $(head -1 ./environment.yml | cut -d' ' -f2)" > ~/.bashrc
ENV PATH /opt/conda/envs/$(head -1 ./environment.yml | cut -d' ' -f2)/bin:$PATH

# Workaround for opencv package issue
# see here: https://stackoverflow.com/questions/72706073/attributeerror-partially-initialized-module-cv2-has-no-attribute-gapi-wip-gs

RUN python -m pip uninstall -y opencv-python
RUN python -m pip install opencv-python==4.5.5.64

# Add TotalSegmentator model weights to container

# links to download totalsegmentator nnunetv2 weights
ENV TOTALSEGMENTATOR_WEIGHTS_URL_1 "http://10.8.95.97:8080/models/totalsegmentator-nnunet/nnunetv2/v2.0.0-weights"
ENV TOTALSEGMENTATOR_WEIGHTS_URL_2 "http://10.8.95.97:8080/models/totalsegmentator-nnunet/nnunetv2/v2.0.4-weights"

RUN mkdir -m777 /app/totalsegmentator
ENV WEIGHTS_DIR="/app/totalsegmentator/nnunet/results/nnUNet/3d_fullres/"
RUN mkdir -m777 -p ${WEIGHTS_DIR}

# Uncomment parts 1 to 5 for full res - GPU preferred!!

# # Part 1 - Organs
ENV WEIGHTS_URL_1=${TOTALSEGMENTATOR_WEIGHTS_URL_1}"/Dataset291_TotalSegmentator_part1_organs_1559subj.zip"
ENV WEIGHTS_ZIP_1="Dataset291_TotalSegmentator_part1_organs_1559subj.zip"

RUN wget --directory-prefix ${WEIGHTS_DIR} ${WEIGHTS_URL_1} \
    && unzip ${WEIGHTS_DIR}${WEIGHTS_ZIP_1} -d ${WEIGHTS_DIR} \
    && rm ${WEIGHTS_DIR}${WEIGHTS_ZIP_1}

# # Part 2 - Vertebrae
ENV WEIGHTS_URL_2=${TOTALSEGMENTATOR_WEIGHTS_URL_1}"/Dataset292_TotalSegmentator_part2_vertebrae_1532subj.zip"
ENV WEIGHTS_ZIP_2="Dataset292_TotalSegmentator_part2_vertebrae_1532subj.zip"

RUN wget --directory-prefix ${WEIGHTS_DIR} ${WEIGHTS_URL_2} \
    && unzip ${WEIGHTS_DIR}${WEIGHTS_ZIP_2} -d ${WEIGHTS_DIR} \
    && rm ${WEIGHTS_DIR}${WEIGHTS_ZIP_2}

# # Part 3 - Cardiac
ENV WEIGHTS_URL_3=${TOTALSEGMENTATOR_WEIGHTS_URL_1}"/Dataset293_TotalSegmentator_part3_cardiac_1559subj.zip"
ENV WEIGHTS_ZIP_3="Dataset293_TotalSegmentator_part3_cardiac_1559subj.zip"

RUN wget --directory-prefix ${WEIGHTS_DIR} ${WEIGHTS_URL_3} \
    && unzip ${WEIGHTS_DIR}${WEIGHTS_ZIP_3} -d ${WEIGHTS_DIR} \
    && rm ${WEIGHTS_DIR}${WEIGHTS_ZIP_3}

# # Part 4 - Muscles
ENV WEIGHTS_URL_4=${TOTALSEGMENTATOR_WEIGHTS_URL_1}"/Dataset294_TotalSegmentator_part4_muscles_1559subj.zip"
ENV WEIGHTS_ZIP_4="Dataset294_TotalSegmentator_part4_muscles_1559subj.zip"

RUN wget --directory-prefix ${WEIGHTS_DIR} ${WEIGHTS_URL_4} \
    && unzip ${WEIGHTS_DIR}${WEIGHTS_ZIP_4} -d ${WEIGHTS_DIR} \
    && rm ${WEIGHTS_DIR}${WEIGHTS_ZIP_4}

# # Part 5 - Ribs
ENV WEIGHTS_URL_5=${TOTALSEGMENTATOR_WEIGHTS_URL_1}"/Dataset295_TotalSegmentator_part5_ribs_1559subj.zip"
ENV WEIGHTS_ZIP_5="Dataset295_TotalSegmentator_part5_ribs_1559subj.zip"

RUN wget --directory-prefix ${WEIGHTS_DIR} ${WEIGHTS_URL_5} \
    && unzip ${WEIGHTS_DIR}${WEIGHTS_ZIP_5} -d ${WEIGHTS_DIR} \
    && rm ${WEIGHTS_DIR}${WEIGHTS_ZIP_5}

# Weight 2.0.0 - Task 297 for fast processing
ENV WEIGHTS_URL_7=${TOTALSEGMENTATOR_WEIGHTS_URL_1}"/Dataset297_TotalSegmentator_total_3mm_1559subj.zip"
ENV WEIGHTS_ZIP_7="Dataset297_TotalSegmentator_total_3mm_1559subj.zip"

RUN wget --directory-prefix ${WEIGHTS_DIR} ${WEIGHTS_URL_7} \
    && unzip ${WEIGHTS_DIR}${WEIGHTS_ZIP_7} -d ${WEIGHTS_DIR} \
    && rm ${WEIGHTS_DIR}${WEIGHTS_ZIP_7}

# Weight 2.0.0 - Task 298 for fast fast processing
ENV WEIGHTS_URL_8=${TOTALSEGMENTATOR_WEIGHTS_URL_1}"/Dataset298_TotalSegmentator_total_6mm_1559subj.zip"
ENV WEIGHTS_ZIP_8="Dataset298_TotalSegmentator_total_6mm_1559subj.zip"

RUN wget --directory-prefix ${WEIGHTS_DIR} ${WEIGHTS_URL_8} \
    && unzip ${WEIGHTS_DIR}${WEIGHTS_ZIP_8} -d ${WEIGHTS_DIR} \
    && rm ${WEIGHTS_DIR}${WEIGHTS_ZIP_8}

# Weight 2.0.4 - Task 297 for fast processing
ENV WEIGHTS_URL_9=${TOTALSEGMENTATOR_WEIGHTS_URL_2}"/Dataset297_TotalSegmentator_total_3mm_1559subj_v204.zip"
ENV WEIGHTS_ZIP_9="Dataset297_TotalSegmentator_total_3mm_1559subj_v204.zip"

RUN wget --directory-prefix ${WEIGHTS_DIR} ${WEIGHTS_URL_9} \
    && unzip ${WEIGHTS_DIR}${WEIGHTS_ZIP_9} -d ${WEIGHTS_DIR} \
    && rm ${WEIGHTS_DIR}${WEIGHTS_ZIP_9}


# Set TOTALSEG_WEIGHTS_PATH ENV variable – this is auto-detected by TotalSegmentator
# See: https://github.com/wasserth/TotalSegmentator/blob/f4651171a4c6eae686dd67b77efe6aa78911734d/totalsegmentator/libs.py#L77
ENV TOTALSEG_WEIGHTS_PATH="/app/totalsegmentator/nnunet/results/"
RUN chmod -R 777 /app/totalsegmentator

WORKDIR /app
CMD ["./docker-entrypoint.sh"]