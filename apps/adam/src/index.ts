import { Context } from "aws-lambda";

type RootEvent = {
  input: DataEvent;
};

type DataEvent = {
  inputX: string;
  inputY: string;
};

export const handler = async (event: RootEvent, context: Context) => {
  console.log(event);
  return event.input.inputX;
};
