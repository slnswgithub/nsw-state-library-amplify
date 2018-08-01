RSpec.describe TranscriptService, type: :service do
  describe "#reset" do
    let!(:user) { FactoryBot.create :user }
    let!(:transcript) do
      FactoryBot.create :transcript,
                        transcript_status_id: 1,
                        percent_completed: 10,
                        lines_completed: 5,
                        percent_edited: 15,
                        lines_edited: 6,
                        percent_reviewing: 2,
                        lines_reviewing: 2,
                        users_contributed: 1
    end
    let!(:speaker) { FactoryBot.create :speaker }

    let(:collection) { transcript.collection }

    let!(:transcript_speaker) do
      FactoryBot.create :transcript_speaker,
                        transcript: transcript,
                        collection_id: collection.id,
                        speaker: speaker
    end

    let!(:transcript_line) do
      FactoryBot.create :transcript_line,
                        transcript: transcript,
                        transcript_line_status_id: 2,
                        guess_text: "Guess text",
                        flag_count: 1
    end

    let!(:transcript_edit) do
      FactoryBot.create :transcript_edit,
                        transcript: transcript,
                        transcript_line: transcript_line,
                        user_id: user.id
    end

    let!(:speaker_edits) do
      FactoryBot.create :transcript_speaker_edit,
                        transcript: transcript,
                        transcript_line: transcript_line,
                        user_id: user.id,
                        speaker_id: speaker.id
    end

    let(:speaker_edits_count) do
      TranscriptSpeakerEdit.
        where(transcript_id: transcript.id).count
    end

    # rubocop:disable RSpec/ExampleLength
    it "has existing values" do
      # transcript
      expect(transcript.transcript_status_id).to eq(1)
      expect(transcript.percent_completed).to eq(10)
      expect(transcript.lines_completed).to eq(5)
      expect(transcript.percent_edited).to eq(15)
      expect(transcript.lines_edited).to eq(6)
      expect(transcript.percent_reviewing).to eq(2)
      expect(transcript.lines_reviewing).to eq(2)
      expect(transcript.users_contributed).to eq(1)

      # transcript line
      expect(transcript_line.transcript_line_status_id).to eq(2)
      expect(transcript_line.guess_text).to eq("Guess text")
      expect(transcript_line.flag_count).to eq(1)

      # transcript edits
      expect(transcript.transcript_edits.count).to eq(1)

      # speaker edits
      expect(speaker_edits_count).to eq(1)
    end
    # rubocop:enable RSpec/ExampleLength

    context "when reset the transcript" do
      before do
        described_class.new(transcript).reset
      end

      # rubocop:disable RSpec/ExampleLength
      it "reset the transcript values" do
        expect(transcript.transcript_status_id).to eq(0)
        expect(transcript.percent_completed).to eq(0)
        expect(transcript.lines_completed).to eq(0)
        expect(transcript.percent_edited).to eq(0)
        expect(transcript.lines_edited).to eq(0)
        expect(transcript.percent_reviewing).to eq(0)
        expect(transcript.lines_reviewing).to eq(0)
        expect(transcript.users_contributed).to eq(0)
      end
      # rubocop:enable RSpec/ExampleLength

      it "reset all the transcript lines" do
        transcript_line.reload
        expect(transcript_line.transcript_line_status_id).to eq(1)
        expect(transcript_line.guess_text).to eq("")
        expect(transcript_line.flag_count).to eq(0)
      end

      it "deletes all the transcript edits" do
        expect(transcript.transcript_edits.count).to eq(0)
      end

      it "deletes all the speaker edits" do
        expect(speaker_edits_count).to eq(0)
      end
    end
  end
end
