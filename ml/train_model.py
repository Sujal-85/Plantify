import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
import os

# CONFIGURATION
# Resolve paths relative to this script file
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# The user should place their dataset in the 'assets/plant_dataset' directory
DATASET_DIR = os.path.join(BASE_DIR, '../assets/plant_dataset')
IMG_SIZE = (224, 224)
BATCH_SIZE = 16 # Reduced for larger models to prevent OOM errors
EPOCHS = 25 # Increased for better convergence
# Save model and labels in the same directory as this script (ml/)
MODEL_SAVE_PATH = os.path.join(BASE_DIR, 'plant_disease_model.tflite')
LABELS_SAVE_PATH = os.path.join(BASE_DIR, 'plant_labels.txt')

def train_and_export():
    # 1. VISUALIZE DATASET
    if not os.path.exists(DATASET_DIR):
        print(f"Error: Dataset directory '{DATASET_DIR}' not found.")
        print("Please create a folder named 'plant_dataset' in the 'assets' directory and organize your plant images in subfolders (one for each category).")
        return

    print("Loading images...")
    
    # Data Generator (with augmentation)
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=30,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest',
        validation_split=0.2
    )

    train_generator = train_datagen.flow_from_directory(
        DATASET_DIR,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training'
    )

    validation_generator = train_datagen.flow_from_directory(
        DATASET_DIR,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation'
    )

    # Save Labels
    labels = list(train_generator.class_indices.keys())
    with open(LABELS_SAVE_PATH, 'w') as f:
        f.write('\n'.join(labels))
    print(f"Labels saved to {LABELS_SAVE_PATH}: {labels}")

    # 2. BUILD MODEL (Transfer Learning with MobileNetV2)
    base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=IMG_SIZE + (3,))
    
    # Fine-tuning: unfreeze the top layers of the model
    base_model.trainable = True
    for layer in base_model.layers[:-20]:
        layer.trainable = False

    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dropout(0.5)(x) # Increased dropout for regularization
    predictions = Dense(len(labels), activation='softmax')(x)

    model = Model(inputs=base_model.input, outputs=predictions)

    # Load Checkpoint if exists
    CHECKPOINT_PATH = os.path.join(BASE_DIR, 'checkpoint.weights.h5')
    if os.path.exists(CHECKPOINT_PATH):
        print(f"Resuming from checkpoint: {CHECKPOINT_PATH}")
        model.load_weights(CHECKPOINT_PATH)
    
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001), loss='categorical_crossentropy', metrics=['accuracy'])

    # Callbacks
    checkpoint_callback = tf.keras.callbacks.ModelCheckpoint(
        filepath=CHECKPOINT_PATH,
        save_weights_only=True,
        monitor='val_accuracy',
        mode='max',
        save_best_only=True,
        verbose=1
    )

    lr_scheduler = tf.keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.2,
        patience=3,
        min_lr=0.00001
    )

    # 3. TRAIN
    print("Starting training...")
    try:
        model.fit(
            train_generator,
            steps_per_epoch=train_generator.samples // BATCH_SIZE,
            validation_data=validation_generator,
            validation_steps=validation_generator.samples // BATCH_SIZE,
            epochs=EPOCHS,
            callbacks=[checkpoint_callback, lr_scheduler]
        )
    except KeyboardInterrupt:
        print("\nTraining interrupted by user. Saving current state...")
        model.save_weights(CHECKPOINT_PATH)
        print("Checkpoint saved.")
        return

    # 4. CONVERT TO TFLITE
    print("Converting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    with open(MODEL_SAVE_PATH, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Success! Model saved to {MODEL_SAVE_PATH}")
    print("\nNEXT STEPS:")
    print(f"1. Place your expanded dataset in: {DATASET_DIR}")
    print("2. Run this script to train the new model.")
    print(f"3. Move '{MODEL_SAVE_PATH}' to your Flutter app: assets/ml/plant_disease_model.tflite")
    print(f"4. Move '{LABELS_SAVE_PATH}' to your Flutter app: assets/ml/plant_labels.txt")
    print("5. Update your app's database to include detailed treatments for the new plant categories.")

if __name__ == '__main__':
    train_and_export()
